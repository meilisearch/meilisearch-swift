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
        dump(taskRes)
        if taskRes.status == Task.Status.succeeded {
          completion()
          return
        }
        request()
      case .failure(let error):
        dump("HEYYYYYY")
        dump(error)
        XCTFail()
      }
    }
  }
  request()
}
