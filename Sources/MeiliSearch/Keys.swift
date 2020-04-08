import Foundation

struct Keys {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
      self.request = request
    }

  func get(
    _ masterKey: String,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {

        let headers: [String: String] = ["X-Meili-API-Key": masterKey]

        self.request.get(api: "/keys", headers: headers) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Key = try decoder.decode(Key.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}
