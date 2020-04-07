import Foundation

final class Indexes {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (config: Config) {
        request = Request(config: config)
    }

    func get(uid: String, _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(uid)") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }
                
                Indexes.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func getAll(_ completion: @escaping (Result<[Index], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                Indexes.decodeJSONArray(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func create(uid: String, _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

        let payload = CreateIndexPayload(uid: uid)
        let jsonData = try! JSONEncoder().encode(payload)

        self.request.post(api: "/indexes", body: jsonData) { result in

            switch result {
            case .success(let data):

                Indexes.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func update(uid: String, name: String, _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

        let payload = UpdateIndexPayload(name: name)
        let jsonData = try! JSONEncoder().encode(payload)

        self.request.put(api: "/indexes/\(uid)", body: jsonData) { result in

            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func delete(uid: String, _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(uid)") { result in

            switch result {
            case .success:
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    private static func decodeJSON(
        _ data: Data,
        _ completion: (Result<Index, Swift.Error>) -> Void) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            let update: Index = try decoder.decode(Index.self, from: data)
            completion(.success(update))
        } catch {
            completion(.failure(error))
        }
    }

    private static func decodeJSONArray(
        _ data: Data,
        _ completion: (Result<[Index], Swift.Error>) -> Void) {
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
            let update: [Index] = try decoder.decode([Index].self, from: data)
            completion(.success(update))
        } catch {
            completion(.failure(error))
        }
    }

}

struct CreateIndexPayload: Codable {
    let uid: String
}

struct UpdateIndexPayload: Codable {
    let name: String
}
