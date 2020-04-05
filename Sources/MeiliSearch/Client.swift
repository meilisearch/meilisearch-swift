import Foundation

public class MeiliSearchClient {

    private let config: Config
    private let indexes: Indexes
    private let documents: Documents
    private let search: Search
    private let system: System
    private let stats: Stats

    public init(_ config: Config) {
        self.config = config
        self.indexes = Indexes(config: config)
        self.documents = Documents(config: config)
        self.search = Search(config: config)
        self.system = System(config: config)
        self.stats = Stats(config: config)
    }

    public func createIndex(
        uid: String,
        _ completion: @escaping (Result<Index, Error>) -> Void) {
        self.indexes.create(uid: uid, completion)
    }

    public func getIndex(
        uid: String,
        _ completion: @escaping (Result<Index, Error>) -> Void) {
        self.indexes.get(uid: uid, completion)
    }

    public func getIndexes(_ completion: @escaping (Result<[Index], Error>) -> Void) {
        self.indexes.getAll(completion)
    }

    public func updateIndex(
        uid: String,
        name: String,
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.indexes.update(uid: uid, name: name, completion)
    }

    public func deleteIndex(
        uid: String,
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.indexes.delete(uid: uid, completion)
    }

    public func addOrReplaceDocument(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Error>) -> Void) {
        self.documents.addOrReplace(
            uid: uid,
            document: document,
            primaryKey: primaryKey,
            completion)
    }

    public func addOrUpdateDocument(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Error>) -> Void) {
        self.documents.addOrUpdate(
            uid: uid,
            document: document,
            primaryKey: primaryKey,
            completion)
    }

    public func getDocument(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<[String: Any], Error>) -> Void) {
        self.documents.get(uid: uid, identifier: identifier, completion)
    }

    public func getDocuments(
        uid: String,
        limit: Int,
        _ completion: @escaping (Result<[[String: Any]], Error>) -> Void) {
        self.documents.getAll(uid: uid, limit: limit, completion)
    }

    public func deleteDocument(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<Update, Error>) -> Void) {
        self.documents.delete(uid: uid, identifier: identifier, completion)
    }

    public func deleteAllDocuments(
        uid: String,
        _ completion: @escaping (Result<Update, Error>) -> Void) {
        self.documents.deleteAll(uid: uid, completion)
    }

    public func search(
        uid: String, 
        searchParameters: SearchParameters, 
        _ completion: @escaping (Result<SearchResult, Error>) -> Void) {
        self.search.search(uid: uid, searchParameters: searchParameters, completion)
    }

    public func health(_ completion: @escaping (Result<(), Error>) -> Void) {
        self.system.health(completion)
    }

    public func version(_ completion: @escaping (Result<Version, Error>) -> Void) {
        self.system.version(completion)
    }

    public func systemInfo(_ completion: @escaping (Result<SystemInfo, Error>) -> Void) {
        self.system.systemInfo(completion)
    }

    public func stat(uid: String, _ completion: @escaping (Result<Stat, Error>) -> Void) {
        self.stats.stat(uid: uid, completion)
    }

    public func allStats(_ completion: @escaping (Result<AllStats, Error>) -> Void) {
        self.stats.allStats(completion)
    }

}
