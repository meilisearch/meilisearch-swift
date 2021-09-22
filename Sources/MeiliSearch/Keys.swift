import Foundation

struct Keys {

  // MARK: Properties

  let request: Request
  let config: Config

  // MARK: Initializers

  init (_ request: Request, _ config: Config) {
    self.request = request
    self.config = config
  }

  func get(_ completion: @escaping (Result<Key, Swift.Error>) -> Void) {

    self.request.get(api: "/keys") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let decoder: JSONDecoder = JSONDecoder()
          let key: Key = try decoder.decode(Key.self, from: data)
          completion(.success(key))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
