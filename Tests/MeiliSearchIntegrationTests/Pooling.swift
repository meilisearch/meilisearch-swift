//
//  File.swift
//
//
//  Created by Pedro Paulo de Amorim on 23/09/2020.
//

import Foundation
import XCTest
@testable import MeiliSearch

public func pool(_ client: MeiliSearch) {

  autoreleasepool {

    let semaphore = DispatchSemaphore(value: 0)
    var success: Bool = false

    while true {
      client.health { result in
        switch result {
        case .success:
          success = true
        case .failure:
          Thread.sleep(forTimeInterval: 0.5)
          success = false
        }
        semaphore.signal()
      }
      if !success {
        semaphore.wait()
        continue
      }
      break
    }

  }

}

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
