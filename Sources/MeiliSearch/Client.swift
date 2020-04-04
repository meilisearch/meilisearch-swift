import Foundation

public class Client {

    private let config: Config
    private let indexes: Indexes
    private let documents: Documents
    private let system: System
    
    init(_ config: Config) {
        self.config = config
        self.indexes = Indexes(config: config)
        self.documents = Documents(config: config)
        self.system = System(config: config)
    }

    public func createIndex(
        uid: String, 
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.indexes.create(uid: uid, completion);
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

    public func deleteAllIndexes(
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.indexes.deleteAll(completion)
    }

    public func createDocument(
        uid: String,
        document: Data, 
        primaryKey: String, 
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.documents.create(
            uid: uid, 
            document: document, 
            primaryKey: primaryKey, 
            completion)
    }

    public func getDocument(
        uid: String, 
        identifier: String, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {
        self.documents.get(uid: uid, identifier: identifier, completion)
    }

    public func getDocuments(
        uid: String,
        limit: Int,
        _ completion: @escaping (Result<Data, Error>) -> Void) {
        self.documents.getAll(uid: uid, limit: limit, completion)
    }

    public func deleteDocument(
        uid: String, 
        identifier: String, 
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.documents.delete(uid: uid, identifier: identifier, completion)
    }

    public func deleteAllDocuments(
        uid: String, 
        _ completion: @escaping (Result<(), Error>) -> Void) {
        self.documents.deleteAll(uid: uid, completion)
    }

    public func health(_ completion: @escaping (Result<(), Error>) -> Void) {
        self.system.health(completion)
    }

    public func version(_ completion: @escaping (Result<(), Error>) -> Void) {
        self.system.version(completion)
    }

    public func sysInfo(_ completion: @escaping (Result<(), Error>) -> Void) {
        self.system.sysInfo(completion)
    }
    
}
