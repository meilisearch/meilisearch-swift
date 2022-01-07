import Foundation
import XCTest
@testable import MeiliSearch

public func waitForPendingUpdate(
  _ client: MeiliSearch,
  _ uid: String,
  _ update: Update,
  _ completion: @escaping () -> Void) {
  func request() {
    client.index(uid).getUpdate(update.updateId) { result in
      switch result {
      case .success(let updateResult):
        if updateResult.status == Task.Status.processed {
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
