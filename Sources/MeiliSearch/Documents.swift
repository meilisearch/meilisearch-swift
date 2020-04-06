import Foundation

final class Documents {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (config: Config) {
        request = Request(config: config)
    }

    func addOrReplace(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Error>) -> Void) {

        var query: String = "/indexes/\(uid)/documents"
        if let primaryKey: String = primaryKey {
            query += "?primaryKey=\(primaryKey)"
        }

        request.post(api: query, body: document) { result in

            switch result {
            case .success(let data):
                decodeUpdateJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func addOrUpdate(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Error>) -> Void) {

        var query: String = "/indexes/\(uid)/documents"
        if let primaryKey: String = primaryKey {
            query += "?primaryKey=\(primaryKey)"
        }

        request.put(api: query, body: document) { result in

            switch result {
            case .success(let data):
                decodeUpdateJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func get(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<[String: Any], Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents/\(identifier)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    fatalError()
                }

                do {
                    let dictionary = try JSONSerialization
                        .jsonObject(with: data, options: []) as! [String: Any]
                    completion(.success(dictionary))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func getAll(
        uid: String,
        limit: Int = -1,
        _ completion: @escaping (Result<[[String: Any]], Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents?limit=\(limit)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    fatalError()
                }

                do {
                    let dictionaries = try JSONSerialization
                        .jsonObject(with: data, options: []) as! [[String: Any]]
                    completion(.success(dictionaries))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func delete(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<Update, Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents/\(identifier)") { result in

            switch result {
            case .success(let data):
                guard let data = data else {
                    return
                }
                decodeUpdateJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func deleteAll(
        uid: String,
        _ completion: @escaping (Result<Update, Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents") { result in

            switch result {
            case .success(let data):
                guard let data = data else {
                    return
                }
                decodeUpdateJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}

private func decodeUpdateJSON(
    _ data: Data,
    _ completion: (Result<Update, Error>) -> Void) {
    do {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let update: Update = try decoder.decode(Update.self, from: data)
        completion(.success(update))
    } catch {
        completion(.failure(error))
    }
}
