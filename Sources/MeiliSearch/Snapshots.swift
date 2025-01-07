import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 The snapshots route allows the creation of database snapshots.
 */
struct Snapshots {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // MARK: Create

  func create(_ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void) {
    self.request.post(api: "/snapshots", Data()) { result in
      switch result {
      case .success(let data):
        do {
          let result: TaskInfo = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
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
