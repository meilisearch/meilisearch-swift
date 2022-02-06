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
    taskId: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.request.get(api: "/tasks/\(taskId)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let task: Task = try Constants.customJSONDecoder.decode(
            Task.self,
            from: data)
          completion(.success(task))
        } catch {
          dump(error)
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func get(
    uid: String,
    taskId: Int,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/tasks/\(taskId)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let task: Task = try Constants.customJSONDecoder.decode(
            Task.self,
            from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getAll(
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
    self.request.get(api: "/tasks") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: Results<Task> = try Constants.customJSONDecoder.decode(Results<Task>.self, from: data)
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
    uid: String,
    _ completion: @escaping (Result<Results<Task>, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/tasks") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let result: Results<Task> = try Constants.customJSONDecoder.decode(Results<Task>.self, from: data)
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
    _ task: Task,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.get(taskId: task.uid) { result in
        switch result {
        case .success(let status):
          if status.status == Task.Status.succeeded || status.status == Task.Status.failed {
            completion(.success(status))
          } else if 0 - startingDate.timeIntervalSinceNow > options.timeOut {
            completion(.failure(MeiliSearch.Error.timeOut(timeOut: options.timeOut)))
          } else {
            usleep(useconds_t(options.interval * 1000000))
            self.checkStatus(task, options, startingDate, completion)
          }
        case .failure(let error):
          completion(.failure(error))
          return
        }
      }
  }

  private func checkStatus(
    _ uid: String,
    _ task: Task,
    _ options: WaitOptions,
    _ startingDate: Date,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      self.get(uid: uid, taskId: task.uid) { result in
        switch result {
        case .success(let status):
          if status.status == Task.Status.succeeded || status.status == Task.Status.failed {
            completion(.success(status))
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
    task: Task,
    options: WaitOptions? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {
      do {
        let currentDate = Date()
        let waitOptions: WaitOptions = options ?? WaitOptions()

        self.checkStatus(task, waitOptions, currentDate) { result in
          switch result {
          case .success(let status):
            completion(.success(status))
          case .failure(let error):
            completion(.failure(error))
          }
        }
      }
  }
}
