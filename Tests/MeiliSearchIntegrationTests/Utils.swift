import Foundation
import XCTest
@testable import MeiliSearch

public func waitForTask(
  _ client: MeiliSearch,
  _ uid: String,
  _ task: Task,
  _ completion: @escaping () -> Void) {
  func request() {
    client.index(uid).getTask(task.uid) { result in
      switch result {
      case .success(let taskRes):
        if taskRes.status == Task.Status.succeeded {
          completion()
          return
        }
        request()
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
  }
  request()
}
