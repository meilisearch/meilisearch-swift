import Foundation

/**
 The dumps route allows the creation of database dumps. Dumps are `.tar.gz` files that
 can be used to launch MeiliSearch. Dumps are compatible between MeiliSearch versions.
 */
struct Dumps {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // MARK: Create

  func create(_ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.request.post(api: "/dumps", Data()) { result in
      switch result {
      case .success(let data):
        do {
          let result: Dump = try Constants.customJSONDecoder.decode(Dump.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Status

  func status(
    _ uid: String,
    _ completion: @escaping (Result<Dump, Swift.Error>) -> Void) {
    self.request.get(api: "/dumps/\(uid)/status") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: Dump = try Constants.customJSONDecoder.decode(Dump.self, from: data)
          completion(.success(result))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
