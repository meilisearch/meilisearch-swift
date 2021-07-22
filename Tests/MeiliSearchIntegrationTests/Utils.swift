import Foundation
import XCTest
@testable import MeiliSearch

public func waitForPendingUpdate(
  _ client: MeiliSearch,
  _ UID: String,
  _ update: Update,
  _ completion: @escaping () -> Void) {
  func request() {
    client.getUpdate(UID: UID, update) { result in
      switch result {
      case .success(let updateResult):
        if updateResult.status == Update.Status.processed {
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
