import Foundation

/**
 Settings is a list of all the customization possible for an index.
 */
struct Updates {

  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(
    _ UID: String,
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(UID)/updates/\(update.updateId)") { result in

      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let result: Update.Result = try Constants.customJSONDecoder.decode(
            Update.Result.self,
            from: data)
          completion(.success(result))
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
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(UID)/updates") { result in

      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let result: [Update.Result] = try Constants.customJSONDecoder.decode([Update.Result].self, from: data)

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
