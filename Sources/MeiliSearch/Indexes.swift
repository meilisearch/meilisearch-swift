import Foundation

public struct Indexes {

  // MARK: Properties

  let request: Request
  let config: Config
  // let uid: String?

  /// The index uid.
  public let uid: String

  /// The data when the index was created.
  public let createdAt: Date?

  /// The data when the index was last updated.
  public let updatedAt: Date?

  /// The primary key configured for the index.
  public let primaryKey: String?

  // Document methods
  private let documents: Documents

  // Search methods
  private let search: Search

  // Updates methods
  private let updates: Updates

  // Settings methods
  private let settings: Settings

  // Stats methods
  private let stats: Stats

  // MARK: Initializers

  init (
    _ config: Config,
    _ uid: String,
    primaryKey: String? = nil,
    _ createdAt: Date? = nil,
    _ updatedAt: Date? = nil
    ) {
    self.config = config
    self.request = Request(self.config)
    self.uid = uid
    self.primaryKey = primaryKey
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.documents = Documents(Request(config))
    self.search = Search(Request(config))
    self.updates = Updates(Request(config))
    self.settings = Settings(Request(config))
    self.stats = Stats(Request(config))
  }

  // MARK: Functions

  /**
   Get the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func get(_ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSON(result, self.config, completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   List all indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[Index]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public static func getAll(_ config: Config, _ completion: @escaping (Result<[Indexes], Swift.Error>) -> Void) {
    Request(config).get(api: "/indexes") { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSONArray(result, config, completion)
      case .failure(let error):
        completion(.failure(error))
      }

    }

  }

  /**
   Get or create an index.

  - parameter uid:        The unique identifier for the `Index` to be created.
  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public static func getOrCreate(
    _ uid: String,
    primaryKey: String? = nil,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    Indexes.create(uid, primaryKey: primaryKey, config) { result in
      switch result {
      case .success(let index):
        completion(.success(index))
      case .failure(let error):
        switch error {
        case MeiliSearch.Error.meiliSearchApiError(_, let msErrorResponse, _, _):
          if let msErrorBody: MeiliSearch.MSErrorResponse  = msErrorResponse {
            if msErrorBody.errorCode == "index_already_exists" {
              Indexes(config, uid).get(completion)
            }
          } else {
            completion(.failure(error))
          }
        default:
          completion(.failure(error))
        }
      }
    }
  }

  /**
   Create a new Index for the given `uid`.

   - parameter uid:        The unique identifier for the `Index` to be created.
   - parameter primaryKey: the unique field of a document.
   - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public static func create(
    _ uid: String,
    primaryKey: String? = nil,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {

    let payload = CreateIndexPayload(uid: uid, primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    Request(config).post(api: "/indexes", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, config, completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  /**
   Update the index primaryKey.

  - parameter primaryKey: the unique field of a document.
  - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func update(
    primaryKey: String,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {

    let payload: UpdateIndexPayload = UpdateIndexPayload(primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.put(api: "/indexes/\(self.uid)", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, self.config, completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }


  /**
   Delete the index.

  - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func delete(
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.request.delete(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

    // MARK: Document

  /**
   Add a list of documents or replace them if they already exist.

   If you send an already existing document (same id) the whole existing document will
   be overwritten by the new document. Fields previously in the document not present in
   the new document are removed.

   For a partial update of the document see `updateDocuments`.

   - parameter documents:  The documents to add in MeiliSearch.
   - parameter Encoder:    The data structure of your documents.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func addDocuments<T>(
    documents: [T],
    encoder: JSONEncoder? = nil,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) where T: Encodable {
    self.documents.add(
      self.uid,
      documents,
      encoder,
      primaryKey,
      completion)
  }

  /**
   Add a list of documents as data or replace them if they already exist.

   If you send an already existing document (same id) the whole existing document will
   be overwritten by the new document. Fields previously in the document not present in
   the new document are removed.

   For a partial update of the document see `updateDocuments`.

   - parameter documents:  The document data (JSON) to be processed.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func addDocuments(
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.add(
      self.uid,
      documents,
      primaryKey,
      completion)
  }

  /**
    Add a list of documents or update them if they already exist. If the provided index does not exist, it will be created.

    If you send an already existing document (same documentId) the old document will be only partially
    updated according to the fields of the new document.
    Thus, any fields not present in the new document are kept and remained unchanged.

    To completely overwrite a document, `addDocuments`

   - parameter documents:  The documents to add in MeiliSearch.
   - parameter Encoder:    The data structure of your documents.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDocuments<T>(
    documents: [T],
    encoder: JSONEncoder? = nil,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) where T: Encodable {
    self.documents.update(
      self.uid,
      documents,
      encoder,
      primaryKey,
      completion)
  }

  /**
    Add a list of documents or update them if they already exist. If the provided index does not exist, it will be created.

    If you send an already existing document (same documentId) the old document will be only partially
    updated according to the fields of the new document.
    Thus, any fields not present in the new document are kept and remained unchanged.

    To completely overwrite a document, `addDocuments`

   - parameter documents:  The document data (JSON) to be processed.
   - parameter primaryKey: The primary key of a document.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDocuments(
    documents: Data,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.update(
      self.uid,
      documents,
      primaryKey,
      completion
    )
  }

  /**
   Get the Document on the index based on the provided document identifier.

   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getDocument<T>(
    identifier: String,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(self.uid, identifier, completion)
  }

  /**
   Get the Document on the index based on the provided document identifier.

   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `T` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getDocument<T>(
    identifier: Int,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.get(self.uid, String(identifier), completion)
  }

  /**
   List the all Documents.

   - parameter limit:      Limit the size of the query.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains
   `[T]` value. If the request was sucessful or `Error` if a
   failure occured.
   */
  public func getDocuments<T>(
    options: GetParameters? = nil,
    _ completion: @escaping (Result<[T], Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.documents.getAll(self.uid, options, completion)
  }

  /**
   Delete a Document on the index based on the provided document identifier.

   - parameter identifier: The document identifier for the Document to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteDocument(
    identifier: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.delete(self.uid, identifier, completion)
  }

  /**
   Delete all Documents on the index.

   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteAllDocuments(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.deleteAll(self.uid, completion)
  }

  /**
   Delete a selection of documents based on array of document `identifiers`'s.

   - parameter documentsUID: The array of unique identifier for the Document to be deleted.
   - parameter completion:   The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteBatchDocuments(
    _ documentsIdentifiers: [Int],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.documents.deleteBatch(self.uid, documentsIdentifiers, completion)
  }


  // MARK: Search

  /**
   Search in the index.

   - parameter searchParameters: Options on search.
   - parameter completion:       The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `SearchResult<T>`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func search<T>(
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<SearchResult<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.search.search(self.uid, searchParameters, completion)
  }

  // MARK: Updates

  /**
   Get the status of an update of the index.

   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getUpdate(
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
    self.updates.get(self.uid, update, completion)
  }

  /**
   Get the status of an update of the index.

   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getAllUpdates(
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {
    self.updates.getAll(self.uid, completion)
  }

  /**
    Wait for an update to be processed or failed.

    Providing an update id, returned by asynchronous MeiliSearch options, call are made
    to MeiliSearch to check if the update has been processed or if it has failed.

    - parameter updateId:            The id of the update.
    - parameter: options             Optionnal configuration for timeout and interval
    - parameter completion:          The completion closure used to notify when the server
  **/
  public func waitForPendingUpdate(
    update: Update,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Update.Result, Swift.Error>
  ) -> Void) {
    self.updates.waitForPendingUpdate(self.uid, update, options, completion)
  }

  // MARK: Settings

  /**
   Get a list of all the customization possible of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Setting`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSettings(
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {
    self.settings.get(self.uid, completion)
  }

  /**
   Update the settings of the index.

   - parameter setting:    Settings to change.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSettings(
    _ setting: Setting,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.update(self.uid, setting, completion)
  }

  /**
   Reset the settings of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSettings(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.reset(self.uid, completion)
  }

  // MARK: Synonyms

  /**
   Get a list of all synonyms possible of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String: [String]]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSynonyms(
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {
    self.settings.getSynonyms(self.uid, completion)
  }

  /**
   Update the synonyms of the index.

   - parameter setting:    Settings to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSynonyms(
    _ synonyms: [String: [String]]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSynonyms(self.uid, synonyms, completion)
  }

  /**
   Reset the synonyms of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSynonyms(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSynonyms(self.uid, completion)
  }

  // MARK: Stop words

  /**
   Get a list of all stop-words possible of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getStopWords(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getStopWords(self.uid, completion)
  }

  /**
   Update the stop-words of the index.

   - parameter stopWords:  Array of stop-word to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateStopWords(
    _ stopWords: [String]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateStopWords(self.uid, stopWords, completion)
  }

  /**
   Reset the stop-words of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetStopWords(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetStopWords(self.uid, completion)
  }

  // MARK: Ranking rules

  /**
   Get a list of all ranking rules possible of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getRankingRules(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getRankingRules(self.uid, completion)
  }

  /**
   Update the ranking rules of the index.

   - parameter UID:          The unique identifier for the `Index` to be found.
   - parameter rankingRules: Array of ranking rules to be applied into `Index`.
   - parameter completion:   The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateRankingRules(
    _ rankingRules: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateRankingRules(self.uid, rankingRules, completion)
  }

  /**
   Reset the ranking rules of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetRankingRules(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetRankingRules(self.uid, completion)
  }

  // MARK: Distinct Attribute

  /**
   Get the distinct attribute field of an `Index`.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDistinctAttribute(
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {
    self.settings.getDistinctAttribute(self.uid, completion)
  }

  /**
   Update the distinct attribute field of the index.

   - parameter distinctAttribute: The distinct attribute to be applied into `Index`.
   - parameter completion:        The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDistinctAttribute(
    _ distinctAttribute: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDistinctAttribute(
      self.uid,
      distinctAttribute,
      completion)
  }

  /**
   Reset the distinct attribute field of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDistinctAttribute(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDistinctAttribute(self.uid, completion)
  }

  // MARK: Searchable Attribute

  /**
   Get the searchable attribute field of an `Index`.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSearchableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSearchableAttributes(self.uid, completion)
  }

  /**
   Update the searchable attribute field of the index.

   - parameter searchableAttribute: The searchable attribute to be applied into `Index`.
   - parameter completion:          The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSearchableAttributes(
    _ searchableAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSearchableAttributes(
      self.uid,
      searchableAttribute,
      completion)
  }

  /**
   Reset the searchable attribute field of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSearchableAttributes(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSearchableAttributes(self.uid, completion)
  }

  // MARK: Displayed Attribute

  /**
   Get the displayed attribute field of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDisplayedAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getDisplayedAttributes(self.uid, completion)
  }

  /**
   Update the displayed attribute field of the index.

   - parameter UID:                The unique identifier for the `Index` to be found.
   - parameter displayedAttribute: The displayed attribute to be applied into `Index`.
   - parameter completion:         The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDisplayedAttributes(
    _ displayedAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDisplayedAttributes(
      self.uid,
      displayedAttribute,
      completion)
  }

  /**
   Reset the displayed attribute field of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDisplayedAttributes(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDisplayedAttributes(self.uid, completion)
  }

  // MARK: Filterable attributes

  /**
   Get the attributes that are filterable of the index.

   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getFilterableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getFilterableAttributes(self.uid, completion)
  }

  /**
   Update the attributes that are filterable of the index.

   - parameter attributes:   The attributes that are filterable on an `Index`.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateFilterableAttributes(
    _ attributes: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateFilterableAttributes(self.uid, attributes, completion)
  }

  /**
   Reset the attributes that are filterable of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetFilterableAttributes(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetFilterableAttributes(self.uid, completion)
  }

  // MARK: Sortable attributes

  /**
   Get the attributes that are sortable of the index.

   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getSortableAttributes(
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSortableAttributes(self.uid, completion)
  }

  /**
   Update the attributes that are sortable of the index.

   - parameter attributes:      The attributes that are sortable on an `Index`.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateSortableAttributes(
    _ attributes: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSortableAttributes(self.uid, attributes, completion)
  }

  /**
   Reset the attributes that are sortable of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetSortableAttributes(
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSortableAttributes(self.uid, completion)
  }
  // MARK: Stats

  /**
   Get stats of the index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Stat` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func stats(
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    self.stats.stats(self.uid, completion)
  }

  // MARK: Codable

  private static func decodeJSON(
    _ data: Data,
    _ config: Config,
    _ completion: (Result<Indexes, Swift.Error>) -> Void) {
    do {
      let index: Index = try Constants.customJSONDecoder.decode(Index.self, from: data)
      let indexes: Indexes = Indexes(config, index.uid, primaryKey: index.primaryKey, index.createdAt, index.updatedAt)

      completion(.success(indexes))
    } catch {
      completion(.failure(error))
    }
  }

  private static func decodeJSONArray(
    _ data: Data,
    _ config: Config,
    _ completion: (Result<[Indexes], Swift.Error>) -> Void) {
    do {
      let rawIndexes: [Index] = try Constants.customJSONDecoder.decode([Index].self, from: data)
      var indexes: [Indexes] = []
      for rawIndex in rawIndexes {
        indexes.append(Indexes(config, rawIndex.uid, primaryKey: rawIndex.primaryKey, rawIndex.createdAt, rawIndex.updatedAt))
      }
      completion(.success(indexes))
    } catch {
      completion(.failure(error))
    }
  }

}

struct UpdateIndexPayload: Codable {
  let primaryKey: String
}

struct CreateIndexPayload: Codable {
  public let uid: String
  public let primaryKey: String?

  public init(
    uid: String,
    primaryKey: String? = nil
  ) {
    self.uid = uid
    self.primaryKey = primaryKey
  }
}
