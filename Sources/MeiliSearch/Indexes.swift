import Foundation

struct Indexes {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
      self.request = request
    }

    func get(
      _ UID: String,
      _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)") { result in

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

    func create(
      _ UID: String,
      _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

        let payload = CreateIndexPayload(uid: UID)
        let jsonData: Data = try! JSONEncoder().encode(payload)

        self.request.post(api: "/indexes", body: jsonData) { result in

            switch result {
            case .success(let data):

                Indexes.decodeJSON(data, completion)

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func update(
      _ UID: String,
      _ name: String,
      _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

        let payload = UpdateIndexPayload(name: name)
        let jsonData: Data = try! JSONEncoder().encode(payload)

        self.request.put(api: "/indexes/\(UID)", body: jsonData) { result in

            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func delete(
      _ UID: String,
      _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)") { result in

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
            let decoder: JSONDecoder = JSONDecoder()
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
            let decoder: JSONDecoder = JSONDecoder()
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
