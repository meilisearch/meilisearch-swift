import Foundation

/**
  Tasks contains information related to asynchronous tasks in MeiliSearch
 */
struct Tasks {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(
    _ uid: String,
    _ taskId: Int,
    _ completion: @escaping (Result<Task.Result, Swift.Error>) -> Void) {
    self.request.get(api: "/tasks/\(taskId)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: Task.Result = try Constants.customJSONDecoder.decode(
            Task.Result.self,
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
    _ completion: @escaping (Result<[Task.Result], Swift.Error>) -> Void) {

    self.request.get(api: "/tasks") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: [Task.Result] = try Constants.customJSONDecoder.decode([Task.Result].self, from: data)
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
    _ task: Task,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Task.Result, Swift.Error>) -> Void) {
      self.get(uid, task.uid) { result in
        switch result {
        case .success(let status):
            completion(.success(status))
          if status.status == Task.Status.succeeded || status.status == Task.Status.failed {
          } else if 0 - startingDate.timeIntervalSinceNow > options.timeOut {
            completion(.failure(MeiliSearch.Error.timeOut(timeOut: options.timeOut)))
          } else {
            usleep(useconds_t(options.interval * 1000000))
            self.checkStatus(uid, task, options, startingDate, completion)
          }
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }

  func waitForTask(
    _ uid: String,
    _ task: Task,
    _ options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task.Result, Swift.Error>) -> Void) {
      let currentDate = Date()
      let waitOptions: WaitOptions = options ?? WaitOptions()

      self.checkStatus(uid, task, waitOptions, currentDate) { result in
        switch result {
        case .success(let status):
          completion(.success(status))
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }
}
