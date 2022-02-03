import Foundation
import XCTest
@testable import MeiliSearch

public func waitForTask(
  _ client: MeiliSearch,
  _ uid: String,
  _ task: TaskResult,
  _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {
  func request() {
    client.index(uid).getTask(task.uid) { result in
      switch result {
      case .success(let taskRes):
        if taskRes.status == Task.Status.succeeded || taskRes.status == Task.Status.failed {
          completion(.success(taskRes))
          return
        }
        request()
      case .failure(let error):
        dump("wait for task utils fail")
        dump(error)
        completion(.failure(error))
      }
    }
  }
  request()
}

  public func createGenericIndex(client: MeiliSearch, uid: String, _ completion: @escaping(Result<TaskResult, Swift.Error>) -> Void) {
      client.deleteIndex(uid) { result in
        switch result {
        case .success:
          client.createIndex(uid: uid) { result in
            switch result {
            case .success(let task):
              client.waitForTask(task: task) { result in
                switch result {
                  case .success(let task):
                    completion(.success(task))
                  case .failure(let error):
                    completion(.failure(error))
                }
              }
            case .failure(let error):
              completion(.failure(error))
            }
          }
        case .failure(let error):
          completion(.failure(error))
        }
      }
  }
public func deleteIndex(client: MeiliSearch, uid: String, _ completion: @escaping(Result<TaskResult, Swift.Error>) -> Void) {
  client.deleteIndex(uid) { result in
      switch result {
      case .success(let task):
        client.waitForTask(task: task) { result in
          switch result {
            case .success(let task):
              completion(.success(task))
            case .failure(let error):
              completion(.failure(error))
          }
        }
      case .failure(let error):
        dump(error)
        completion(.failure(error))
      }
    }
}
