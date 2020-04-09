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

    private let indexes: Indexes
    private let documents: Documents
    private let search: Search
    private let updates: Updates
    private let keys: Keys
    private let settings: Settings
    private let stats: Stats
    private let system: System

    // MARK: Initializers

    /**
     Obtains a MeiliSearch instance for the given `config`.

     - parameter config: Set the default configuration for the client. 
     */
    public init(_ config: Config = Config.default) throws {
        let request: Request = Request(config)
        self.config = try config.validate(request)
        self.indexes = Indexes(request)
        self.documents = Documents(request)
        self.search = Search(request)
        self.updates = Updates(request)
        self.keys = Keys(request)
        self.settings = Settings(request)
        self.stats = Stats(request)
        self.system = System(request)
    }

    // MARK: Index

    /**
     Create a new Index for the given `uid`.

     - parameter UID:        The unique identifier for the Index to be created.
     - parameter completion: The completion closure used to notify when the server 
     completes the write request, it returns a `Result` object that contains `Index` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func createIndex(
        UID: String,
        _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
        self.indexes.create(UID, completion)
    }

    /**
     Get the Index for the given `uid`.

     - parameter UID:        The unique identifier for the Index to be found.
     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains `Index` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func getIndex(
        UID: String,
        _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
        self.indexes.get(UID, completion)
    }

    /**
     List the all Indexes.
     
     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains `[Index]` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func getIndexes(_ completion: @escaping (Result<[Index], Swift.Error>) -> Void) {
        self.indexes.getAll(completion)
    }

    /**
     Update index name.
     
     - parameter UID:        The unique identifier for the Index to be found.
     - parameter name:       New index name.
     - parameter completion: The completion closure used to notify when the server 
     completes the update request, it returns a `Result` object that contains `()` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func updateIndex(
        UID: String,
        name: String,
        _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
        self.indexes.update(UID, name, completion)
    }

    /**
     Delete the Index for the given `uid`.
     
     - parameter completion: The completion closure used to notify when the server 
     completes the delete request, it returns a `Result` object that contains `()` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func deleteIndex(
        UID: String,
        _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
        self.indexes.delete(UID, completion)
    }

    // MARK: Document

    /**
     Add a list of documents or replace them if they already exist.

     If you send an already existing document (same id) the whole existing document will 
     be overwritten by the new document. Fields previously in the document not present in
     the new document are removed.

     For a partial update of the document see `addOrUpdateDocument`.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter document:   The document data (JSON) to be processed.
     - parameter completion: The completion closure used to notify when the server 
     completes the update request, it returns a `Result` object that contains `Update` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func addOrReplaceDocument(
        UID: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.documents.addOrReplace(
            UID,
            document,
            primaryKey,
            completion)
    }

    /**
     Add a list of documents and update them if they already.

    If you send an already existing document (same id) the old document will be only 
    partially updated according to the fields of the new document. Thus, any fields not 
    present in the new document are kept and remained unchanged.

    To completely overwrite a document see `addOrReplaceDocument`.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter document:   The document data (JSON) to be processed.
     - parameter completion: The completion closure used to notify when the server 
     completes the update request, it returns a `Result` object that contains `Update` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func addOrUpdateDocument(
        UID: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.documents.addOrUpdate(
            UID,
            document,
            primaryKey,
            completion)
    }

    /**
     Get the Document for the given `uid` and `identifier`.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter identifier: The document identifier for the Document to be found.
     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains 
     `[[String: Any]]` value. If the request was sucessful or `Error` if a 
     failure occured.
     */
    public func getDocument(
        UID: String,
        identifier: String,
        _ completion: @escaping (Result<[String: Any], Swift.Error>) -> Void) {
        self.documents.get(UID, identifier, completion)
    }

    /**
     List the all Documents.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter limit:      Limit the size of the query.
     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains 
     `[[String: Any]]` value. If the request was sucessful or `Error` if a 
     failure occured.
     */
    public func getDocuments(
        UID: String,
        limit: Int,
        _ completion: @escaping (Result<[[String: Any]], Swift.Error>) -> Void) {
        self.documents.getAll(UID, limit, completion)
    }

    /**
     Delete the Document for the given `uid` and `identifier`.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter identifier: The document identifier for the Document to be found.
     - parameter completion: The completion closure used to notify when the server 
     completes the delete request, it returns a `Result` object that contains `Update` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func deleteDocument(
        UID: String,
        identifier: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.documents.delete(UID, identifier, completion)
    }

    /**
     Delete all Documents for the given `uid`.
     
     - parameter UID:        The unique identifier for the Document's index to be found.
     - parameter completion: The completion closure used to notify when the server 
     completes the delete request, it returns a `Result` object that contains `Update` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func deleteAllDocuments(
        UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.documents.deleteAll(UID, completion)
    }

    /**
     Delete a selection of documents based on array of document `uid`'s.

     - parameter UID:          The unique identifier for the Document's index to be deleted.
     - parameter documentsUID: The array of unique identifier for the Document to be deleted.
     - parameter completion:   The completion closure used to notify when the server
     completes the delete request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func deleteBatchDocuments(
        UID: String,
        documentsUID: [Int],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.documents.deleteBatch(UID, documentsUID, completion)
    }

    /**
     Search for a document in the `uid` and `searchParameters`
     
     - parameter UID:              The unique identifier for the Document's index to
     be found.
     - parameter searchParameters: The document identifier for the Document to be found.
     - parameter completion:       The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains 
     `SearchResult` value. If the request was sucessful or `Error` if a failure occured.
     */
    public func search(
        UID: String,
        _ searchParameters: SearchParameters,
        _ completion: @escaping (Result<SearchResult, Swift.Error>) -> Void) {
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
        masterKey: String,
        _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
        self.keys.get(masterKey, completion)
    }

    // MARK: Settings

    /**
     Get a list of all the customization possible for an `Index`.

     - parameter UID:        The unique identifier for the Index to be found.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Setting`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func getSetting(
        UID: String,
        _ completion: @escaping (Result<Setting, Swift.Error>) -> Void) {
        self.settings.get(UID, completion)
    }

    /**
     Update the settings for a given `Index`.

     - parameter UID:        The unique identifier for the Index to be found.
     - parameter setting:    Setting to be applied into Index.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func updateSetting(
        UID: String,
        _ setting: Setting,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.settings.update(UID, setting, completion)
    }

    /**
     Reset the settings for a given `Index`.

     - parameter UID:        The unique identifier for the Index to be reset.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func resetSetting(
        UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.settings.reset(UID, completion)
    }

    // MARK: Synonyms

    /**
     Get a list of all synonyms possible for an `Index`.

     - parameter UID:        The unique identifier for the Index to be found.
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

     - parameter UID:        The unique identifier for the Index to be found.
     - parameter setting:    Setting to be applied into Index.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func updateSynonyms(
        UID: String,
        _ synonyms: [String: [String]],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.settings.updateSynonyms(UID, synonyms, completion)
    }

    /**
     Reset the synonyms for a given `Index`.

     - parameter UID:        The unique identifier for the Index to be reset.
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

     - parameter UID:        The unique identifier for the Index to be found.
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

     - parameter UID:        The unique identifier for the Index to be found.
     - parameter setting:    Setting to be applied into Index.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func updateStopWords(
        UID: String,
        _ stopWords: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.settings.updateStopWords(UID, stopWords, completion)
    }

    /**
     Reset the stop-words for a given `Index`.

     - parameter UID:        The unique identifier for the Index to be reset.
     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func resetStopWords(
        UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
        self.settings.resetStopWords(UID, completion)
    }

    // MARK: Stats

    /**
     Get stats of an index.

     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `Stat` value.
     If the request was sucessful or `Error` if a failure occured.
     */
    public func stat(UID: String, _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
        self.stats.stat(UID, completion)
    }

    /**
     Get stats of all indexes.

     - parameter completion: The completion closure used to notify when the server
     completes the query request, it returns a `Result` object that contains `AllStats`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func allStats(_ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
        self.stats.allStats(completion)
    }

    // MARK: System

    /**
     Get health of MeiliSearch server.

     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains `()` value. 
     If the request was sucessful or `Error` if a failure occured.
     */
    public func health(_ completion: @escaping (Result<(), Swift.Error>) -> Void) {
        self.system.health(completion)
    }

    /**
     Get version of MeiliSearch.

     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains `Version` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func version(_ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
        self.system.version(completion)
    }

    /**
     Get system information.

     - parameter completion: The completion closure used to notify when the server 
     completes the query request, it returns a `Result` object that contains `SystemInfo` 
     value. If the request was sucessful or `Error` if a failure occured.
     */
    public func systemInfo(_ completion: @escaping (Result<SystemInfo, Swift.Error>) -> Void) {
        self.system.systemInfo(completion)
    }

}
