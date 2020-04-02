import Foundation

public class Client {

    private let config: Config
    private let indexes: Indexes
    private let documents: Documents
    
    init(_ config: Config) {
        self.config = config
        self.indexes = Indexes(config: config)
        self.documents = Documents(config: config)
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
        _ completion: @escaping (Result<Void, Error>) -> Void) {
        self.indexes.delete(uid: uid, completion)
    }
    
}
