import Foundation

/**
 A `MeiliSearch` instance represents a MeiliSearch client used to easily integrate
 your Swift product with the MeiliSearch server.

 - warning: `MeiliSearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {

  // MARK: Properties

  /**
   Current and immutable MeiliSearch configuration. To change this configuration please
   create a new MeiliSearch instance.
   */
  private(set) var config: Config

  // private let indexes: Indexes
  private let documents: Documents
  private let search: Search
  private let updates: Updates
  private let keys: Keys
  private let settings: Settings
  private let stats: Stats
  private let system: System
  private let dumps: Dumps

  // MARK: Initializers

  /**
   Create an instance of MeiliSearch client.

   - parameter host:   The host to the MeiliSearch http server.
   - parameter apiKey:    The authorisation key to communicate with MeiliSearch.
   - parameter session:   A custom produced URLSessionProtocol.
   */
  public init(host: String, apiKey: String? = nil, session: URLSessionProtocol? = nil) throws {
    self.config = try Config(host: host, apiKey: apiKey, session: session).validate()
    let request: Request = Request(self.config)
    // self.indexes = Indexes(self.config)
    self.documents = Documents(request)
    self.search = Search(request)
    self.updates = Updates(request)
    self.keys = Keys(request, self.config)
    self.settings = Settings(request)
    self.stats = Stats(request)
    self.system = System(request)
    self.dumps = Dumps(request)
  }

  // MARK: Index

  public func index(_ uid: String) -> Indexes {
    Indexes(self.config, uid)
  }
  /**
   Create a new Index for the given `uid`.

   - parameter uid:        The unique identifier for the `Index` to be created.
   - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func createIndex(
    _ uid: String,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    Indexes.create(uid, primaryKey: primaryKey, self.config, completion)
  }

  /**
   Get or create a new Index for the given `uid`.

   - parameter uid:        The unique identifier for the `Index` to be created.
   - parameter completion: The completion closure used to notify when the server
   completes the write request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */

  // DONE
  public func getOrCreateIndex(
    _ uid: String,
    primaryKey: String? = nil,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    Indexes.getOrCreate(uid, primaryKey: primaryKey, self.config, completion)
  }

  /**
   Get the Index for the given `uid`.

   - parameter uid:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Index`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndex(
    _ uid: String,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    self.index(uid).get(completion)
  }

  /**
   List the all Indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[Index]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getIndexes(
    _ completion: @escaping (Result<[Indexes], Swift.Error>) -> Void) {
    Indexes.getAll(self.config, completion)
  }

  /**
   Update index name.

   - parameter uid:        The unique identifier for the `Index` to be found.
   - parameter name:       New index name.
   - parameter completion: The completion closure used to notify when the server
   completes the update request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateIndex(
    _ uid: String,
    primaryKey: String,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    self.index(uid).update(primaryKey: primaryKey, completion)
  }

  /**
   Delete the Index for the given `uid`.

   - parameter completion: The completion closure used to notify when the server
   completes the delete request, it returns a `Result` object that contains `()`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func deleteIndex(
    _ uid: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.index(uid).delete(completion)
  }

  // MARK: Search

  /**
   Search for a document in the `uid` and `searchParameters`

   - parameter UID:              The unique identifier for the Document's index to
   be found.
   - parameter searchParameters: The document identifier for the Document to be found.
   - parameter completion:       The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains  `SearchResult<T>`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func search<T>(
    UID: String,
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<SearchResult<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    self.search.search(UID, searchParameters, completion)
  }

  // MARK: Updates

  /**
   Get the status of an update in a given `Index`.

   - parameter UID:       The unique identifier for the Document's index to
   be found.
   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getUpdate(
    UID: String,
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
    self.updates.get(UID, update, completion)
  }

  /**
   Get the status of an update in a given `Index`.

   - parameter UID:       The unique identifier for the Document's index to
   be found.
   - parameter update:    The update value.
   - parameter completion:The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func getAllUpdates(
    UID: String,
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {
    self.updates.getAll(UID, completion)
  }

  /**
    Wait for an update to be processed or failed.

    Providing an update id, returned by asynchronous MeiliSearch options, call are made
    to MeiliSearch to check if the update has been processed or if it has failed.

    - parameter UID:                 The unique identifier of the `Index`.
    - parameter updateId:            The id of the update.
    - parameter: options             Optionnal configuration for timeout and interval
    - parameter completion:          The completion closure used to notify when the server
  **/
  public func waitForPendingUpdate(
    UID: String,
    update: Update,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Update.Result, Swift.Error>
  ) -> Void) {
    self.updates.waitForPendingUpdate(UID, update, options, completion)
  }

  // MARK: Keys

  /**
   Each instance of MeiliSearch has three keys: a master, a private, and a public. Each key has a given
   set of permissions on the API routes.

   - parameter masterKey:  Master key to access the `keys` function.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Key` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func keys(
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(completion)
  }

  // MARK: Settings

  /**
   Get a list of all the customization possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Setting`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSettings(
    UID: String,
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {
    self.settings.get(UID, completion)
  }

  /**
   Update the settings for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter setting:    Settings to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSettings(
    UID: String,
    _ setting: Setting,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.update(UID, setting, completion)
  }

  /**
   Reset the settings for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSettings(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.reset(UID, completion)
  }

  // MARK: Synonyms

  /**
   Get a list of all synonyms possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String: [String]]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSynonyms(
    UID: String,
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {
    self.settings.getSynonyms(UID, completion)
  }

  /**
   Update the synonyms for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter setting:    Settings to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSynonyms(
    UID: String,
    _ synonyms: [String: [String]]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSynonyms(UID, synonyms, completion)
  }

  /**
   Reset the synonyms for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSynonyms(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSynonyms(UID, completion)
  }

  // MARK: Stop words

  /**
   Get a list of all stop-words possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getStopWords(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getStopWords(UID, completion)
  }

  /**
   Update the stop-words for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter stopWords:  Array of stop-word to be applied into `Index`.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateStopWords(
    UID: String,
    _ stopWords: [String]?,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateStopWords(UID, stopWords, completion)
  }

  /**
   Reset the stop-words for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetStopWords(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetStopWords(UID, completion)
  }

  // MARK: Ranking rules

  /**
   Get a list of all ranking rules possible for an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getRankingRules(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getRankingRules(UID, completion)
  }

  /**
   Update the ranking rules for a given `Index`.

   - parameter UID:          The unique identifier for the `Index` to be found.
   - parameter rankingRules: Array of ranking rules to be applied into `Index`.
   - parameter completion:   The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateRankingRules(
    UID: String,
    _ rankingRules: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateRankingRules(UID, rankingRules, completion)
  }

  /**
   Reset the ranking rules for a given `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetRankingRules(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetRankingRules(UID, completion)
  }

  // MARK: Distinct Attribute

  /**
   Get the distinct attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDistinctAttribute(
    UID: String,
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {
    self.settings.getDistinctAttribute(UID, completion)
  }

  /**
   Update the distinct attribute field of an `Index`.

   - parameter UID:               The unique identifier for the `Index` to be found.
   - parameter distinctAttribute: The distinct attribute to be applied into `Index`.
   - parameter completion:        The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDistinctAttribute(
    UID: String,
    _ distinctAttribute: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDistinctAttribute(
      UID,
      distinctAttribute,
      completion)
  }

  /**
   Reset the distinct attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDistinctAttribute(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDistinctAttribute(UID, completion)
  }

  // MARK: Searchable Attribute

  /**
   Get the searchable attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getSearchableAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSearchableAttributes(UID, completion)
  }

  /**
   Update the searchable attribute field of an `Index`.

   - parameter UID:                 The unique identifier for the `Index` to be found.
   - parameter searchableAttribute: The searchable attribute to be applied into `Index`.
   - parameter completion:          The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateSearchableAttributes(
    UID: String,
    _ searchableAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSearchableAttributes(
      UID,
      searchableAttribute,
      completion)
  }

  /**
   Reset the searchable attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetSearchableAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSearchableAttributes(UID, completion)
  }

  // MARK: Displayed Attribute

  /**
   Get the displayed attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be found.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `[String]`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func getDisplayedAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getDisplayedAttributes(UID, completion)
  }

  /**
   Update the displayed attribute field of an `Index`.

   - parameter UID:                The unique identifier for the `Index` to be found.
   - parameter displayedAttribute: The displayed attribute to be applied into `Index`.
   - parameter completion:         The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func updateDisplayedAttributes(
    UID: String,
    _ displayedAttribute: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateDisplayedAttributes(
      UID,
      displayedAttribute,
      completion)
  }

  /**
   Reset the displayed attribute field of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func resetDisplayedAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetDisplayedAttributes(UID, completion)
  }

  // MARK: Filterable attributes

  /**
   Get the attributes that are filterable of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getFilterableAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getFilterableAttributes(UID, completion)
  }

  /**
   Update the attributes that are filterable of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter attributes:   The attributes that are filterable on an `Index`.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateFilterableAttributes(
    UID: String,
    _ attributes: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateFilterableAttributes(UID, attributes, completion)
  }

  /**
   Reset the attributes that are filterable of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetFilterableAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetFilterableAttributes(UID, completion)
  }

  // MARK: Sortable attributes

  /**
   Get the attributes that are sortable of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains an `[String]`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func getSortableAttributes(
    UID: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.settings.getSortableAttributes(UID, completion)
  }

  /**
   Update the attributes that are sortable of an `Index`.

   - parameter UID:             The unique identifier for the `Index` to be found.
   - parameter attributes:      The attributes that are sortable on an `Index`.
   - parameter completion:      The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func updateSortableAttributes(
    UID: String,
    _ attributes: [String],
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.updateSortableAttributes(UID, attributes, completion)
  }

  /**
   Reset the attributes that are sortable of an `Index`.

   - parameter UID:        The unique identifier for the `Index` to be reset.
   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Update`
   value if the request was successful, or `Error` if a failure occurred.
   */
  public func resetSortableAttributes(
    UID: String,
    _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
    self.settings.resetSortableAttributes(UID, completion)
  }

  // MARK: Stats

  /**
   Get stats of an index.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Stat` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func stat(
    UID: String,
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    self.stats.stat(UID, completion)
  }

  /**
   Get stats of all indexes.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `AllStats`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func allStats(
    _ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    self.stats.allStats(completion)
  }

  // MARK: System

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Health` value.
   If the request was sucessful or `Error` if a failure occured.
   */
  public func health(_ completion: @escaping (Result<Health, Swift.Error>) -> Void) {
    self.system.health(completion)
  }

  /**
   Get health of MeiliSearch server.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Bool` that is `true`
   If the request was sucessful or `false` if a failure occured.
   */
  public func isHealthy(_ completion: @escaping (Bool) -> Void) {
    self.health { result in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }

  /**
   Get version of MeiliSearch.

   - parameter completion: The completion closure used to notify when the server
   completes the query request, it returns a `Result` object that contains `Version`
   value. If the request was sucessful or `Error` if a failure occured.
   */
  public func version(
    _ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
    self.system.version(completion)
  }

  /**
   Triggers a dump creation process. Once the process is complete, a dump is created in the dumps folder.
   If the dumps folder does not exist yet, it will be created.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `UID`
   value that can be used later to check the status of the dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func createDump(_ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.create(completion)
  }

  /**
   Get the status of a dump creation process using the uid returned after calling the dump creation route.
   The returned status could be:

   `Dump.Status.inProgress`: Dump creation is in progress.
   `Dump.Status.failed`: An error occurred during the dump process, and the task was aborted.
   `Dump.Status.done`: Dump creation is finished and was successful.

   - parameter completion: The completion closure used to notify when the server
   completes the dump request, it returns a `Dump` object that contains `UID`
   value that can be used later to check the status of the Dump.
   If the request was successful or `Error` if a failure occurred.
   */
  public func getDumpStatus(
    UID: String,
    _ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.dumps.status(UID, completion)
  }
}
