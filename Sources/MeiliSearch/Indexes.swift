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
  }

  // MARK: Functions

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

   - parameter UID:        The unique identifier for the Document's index to be found.
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

   - parameter UID:        The unique identifier for the Document's index to be found.
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

   - parameter UID:        The unique identifier for the Document's index to be found.
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

   - parameter UID:        The unique identifier for the Document's index to be found.
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

   - parameter UID:        The unique identifier for the Document's index to be found.
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
