import Foundation

/**
 A `MeiliSearch` instance represents a MeiliSearch client used to easily integrate
 your Swift product with the MeiliSearch server.

 - warning: `MeiliSearch` instances are thread safe and can be shared across threads
 or dispatch queues.
 */
public struct MeiliSearch {

    // MARK: Properties

    public var config: Config
    private let indexes: Indexes
    private let documents: Documents
    private let search: Search
    private let keys: Keys
    private let system: System
    private let stats: Stats

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
        self.keys = Keys(request)
        self.system = System(request)
        self.stats = Stats(request)
    }

    // MARK: Index

    /**
     Create a new Index for the given `uid`.

     - parameter uid:        The unique identifier for the Index to be created.
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

     - parameter uid:        The unique identifier for the Index to be found.
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
     
     - parameter uid:        The unique identifier for the Index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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
     
     - parameter uid:        The unique identifier for the Document's index to be found.
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

     - parameter uid:          The unique identifier for the Document's index to be deleted.
     - parameter documentsUID: The array of unique identifier for the Document to be deleted.
     - parameter completion:   The completion closure used to notify when the server
     completes the delete request, it returns a `Result` object that contains `Update`
     value. If the request was sucessful or `Error` if a failure occured.
     */
    func deleteBatchDocuments(
      UID: String,
      documentsUID: [Int],
      _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {
      self.documents.deleteBatch(UID, documentsUID, completion)
    }

    /**
     Search for a document in the `uid` and `searchParameters`
     
     - parameter uid:              The unique identifier for the Document's index to 
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

    // MARK: Keys

  public func keys(
    masterKey: String,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.keys.get(masterKey, completion)
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

    // MARK: Index Stat

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

}
