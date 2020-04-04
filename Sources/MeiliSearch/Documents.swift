import Foundation

final class Documents {

    let request: Request
    
    init (config: Config) {
        request = Request(config: config)
    }

    func create(
        uid: String,
        document: Data, 
        primaryKey: String,
        _ completion: @escaping (Result<(), Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents"

        request.post(api: query, body: document) { result in

            switch result {
            case .success(let data):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func get(
        uid: String, 
        identifier: String, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents/\(identifier)"
        request.get(api: query) { result in
            
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func getAll(
        uid: String, 
        limit: Int = -1, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents?limit=\(limit)"
        request.get(api: query) { result in
            
            switch result {
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func delete(
        uid: String, 
        identifier: String, 
        _ completion: @escaping (Result<(), Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents/\(identifier)") { result in

            switch result {
            case .success(let data):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func deleteAll(
        uid: String,
        _ completion: @escaping (Result<(), Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents") { result in

            switch result {
            case .success(let data):
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}