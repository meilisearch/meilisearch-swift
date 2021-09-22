import Foundation

/**
  Updates contains information related to asynchronous tasks in MeiliSearch
 */
struct Updates {

  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(
    _ uid: String,
    _ update: Update,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/updates/\(update.updateId)") { result in
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
    _ uid: String,
    _ completion: @escaping (Result<[Update.Result], Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(uid)/updates") { result in

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

  private func checkStatus(
    _ uid: String,
    _ update: Update,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
      self.get(uid, update) { result in
        switch result {
        case .success(let status):
          if status.status == Update.Status.processed || status.status == Update.Status.failed {
            completion(.success(status))
          } else if 0 - startingDate.timeIntervalSinceNow > options.timeOut {
            completion(.failure(MeiliSearch.Error.timeOut(timeOut: options.timeOut)))
          } else {
            usleep(useconds_t(options.interval * 1000000))
            self.checkStatus(uid, update, options, startingDate, completion)
          }
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }

  func waitForPendingUpdate(
    _ uid: String,
    _ update: Update,
    _ options: WaitOptions? = nil,
    _ completion: @escaping (Result<Update.Result, Swift.Error>) -> Void) {
      let currentDate = Date()
      let waitOptions: WaitOptions = options ?? WaitOptions()

      self.checkStatus(uid, update, waitOptions, currentDate) { result in
        switch result {
        case .success(let status):
          completion(.success(status))
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }

}
