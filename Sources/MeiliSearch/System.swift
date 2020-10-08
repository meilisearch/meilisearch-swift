import Foundation

struct System {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init(_ request: Request) {
        self.request = request
    }

    // MARK: Functions

    func health(_ completion: @escaping (Result<(), Swift.Error>) -> Void) {
        request.get(api: "/health") { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func updateHealth(_ health: Bool, _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
        let data: Data

        do {
            data = try JSONEncoder().encode(CreateHealthPayload(health: health))
        } catch {
            completion(.failure(MeiliSearch.Error.invalidJSON))
            return
        }

        request.put(api: "/health", data) { result in
            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func version(_ completion: @escaping (Result<Version, Swift.Error>) -> Void) {
        request.get(api: "/version") { result in
            switch result {
            case .success(let data):
                guard let data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let vesion: Version = try Constants.customJSONDecoder.decode(Version.self, from: data)

                    completion(.success(vesion))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private struct CreateHealthPayload: Codable {
    let health: Bool
}
