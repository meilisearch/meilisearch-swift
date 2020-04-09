import Foundation

struct Documents {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
        self.request = request
    }

    // MARK: Query

    func get(
        _ UID: String,
        _ identifier: String,
        _ completion: @escaping (Result<[String: Any], Swift.Error>) -> Void) {

        let query: String = "/indexes/\(UID)/documents/\(identifier)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let dictionary: [String: Any] = try JSONSerialization
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
        _ UID: String,
        _ limit: Int = -1,
        _ completion: @escaping (Result<[[String: Any]], Swift.Error>) -> Void) {

        let query: String = "/indexes/\(UID)/documents?limit=\(limit)"
        request.get(api: query) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let dictionaries: [[String: Any]] = try JSONSerialization
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

    // MARK: Write

    func addOrReplace(
        _ UID: String,
        _ document: Data,
        _ primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        var query: String = "/indexes/\(UID)/documents"
        if let primaryKey: String = primaryKey {
            query += "?primaryKey=\(primaryKey)"
        }

        request.post(api: query, document) { result in

            switch result {
            case .success(let data):

              Documents.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }
    }

    func addOrUpdate(
        _ UID: String,
        _ document: Data,
        _ primaryKey: String?,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        var query: String = "/indexes/\(UID)/documents"
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

    // MARK: Delete

    func delete(
        _ UID: String,
        _ identifier: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/documents/\(identifier)") { result in

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
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/documents") { result in

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

    func deleteBatch(
        _ UID: String,
        _ documentsUID: [Int],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

      let data: Data

        do {
          data = try JSONSerialization.data(withJSONObject: documentsUID, options: [])
        } catch {
          completion(.failure(MeiliSearch.Error.invalidJSON))
          return
        }

        self.request.post(api: "/indexes/\(UID)/delete-batch", data) { result in

            switch result {
            case .success(let data):

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
            let decoder: JSONDecoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            let update: Update = try decoder.decode(Update.self, from: data)
            completion(.success(update))
        } catch {
            completion(.failure(error))
        }
    }

}
