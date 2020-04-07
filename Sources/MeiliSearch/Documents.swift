import Foundation

final class Documents {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (config: Config) {
        request = Request(config: config)
    }

    // MARK: Write

    func addOrReplace(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        var query: String = "/indexes/\(uid)/documents"
        if let primaryKey: String = primaryKey {
            query += "?primaryKey=\(primaryKey)"
        }

        request.post(api: query, body: document) { result in

            switch result {
            case .success(let data):

              Documents.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func addOrUpdate(
        uid: String,
        document: Data,
        primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        var query: String = "/indexes/\(uid)/documents"
        if let primaryKey: String = primaryKey {
            query += "?primaryKey=\(primaryKey)"
        }

        request.put(api: query, body: document) { result in

            switch result {
            case .success(let data):

                Documents.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    // MARK: Query

    func get(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<[String: Any], Swift.Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents/\(identifier)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
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
        _ completion: @escaping (Result<[[String: Any]], Swift.Error>) -> Void) {

        let query: String = "/indexes/\(uid)/documents?limit=\(limit)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
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

    // MARK: Delete

    func delete(
        uid: String,
        identifier: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents/\(identifier)") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                Documents.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func deleteAll(
        uid: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)/documents") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                Documents.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    private static func decodeJSON(
        _ data: Data,
        _ completion: (Result<Update, Swift.Error>) -> Void) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            let update: Update = try decoder.decode(Update.self, from: data)
            completion(.success(update))
        } catch {
            completion(.failure(error))
        }
    }

}
