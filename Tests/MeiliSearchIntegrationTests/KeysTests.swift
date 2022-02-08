@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_try
private struct Movie: Codable, Equatable {
  let id: Int
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
  }
}

class KeysTests: XCTestCase {
  private var client: MeiliSearch!
  private var key: Key!
  private var session: URLSessionProtocol!

  // MARK: Setup

  override func setUp() {
    super.setUp()
    session = URLSession(configuration: .ephemeral)
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    let keyException = XCTestExpectation(description: "Get all keys")

    self.client.getKeys { result in
      switch result {
      case .success(let keys):
        dump(keys)
        self.key = keys.results.first
        keyException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get keys")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }

  func testGetKeys() {
    let keyException = XCTestExpectation(description: "Get all keys")

    self.client.getKeys { result in
      switch result {
      case .success(let keys):
        XCTAssertNotEqual(keys.results.count, 0)
        keyException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all keys")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }

  func testGetKey() {
    let keyException = XCTestExpectation(description: "Get one key")

    self.client.getKey(key: self.key.key) { result in
      switch result {
      case .success(let key):
        XCTAssertNotNil(key.description)
        keyException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get a key")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }

  func testCreateKey() {
    let keyException = XCTestExpectation(description: "Create a key")

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        XCTAssertEqual(key.expiresAt, nil)
        keyException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyException.fulfill()
      }
    }

    self.wait(for: [keyException], timeout: 10.0)
  }

  func testCreateKeyWithExpire() {
    let keyException = XCTestExpectation(description: "Create a key with an expireAt value")

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let someDateTime = formatter.string(from: Date.distantFuture)

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: someDateTime)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        XCTAssertNotNil(key.expiresAt)
        keyException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }

  func testUpdateKey() {
    let keyException = XCTestExpectation(description: "Update a key")

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let newDate = formatter.string(from: Date.distantFuture)
        let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: newDate)
        self.client.updateKey(key: key.key, keyParams: keyParams) { result in
          switch result {
          case .success(let key):
            XCTAssertNotNil(key.expiresAt)
            keyException.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to update a key")
            keyException.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }

  func testDeleteKey() {
    let keyException = XCTestExpectation(description: "Delete a key")

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        self.client.deleteKey(key: key.key) { result in
          switch result {
          case .success:
            keyException.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to delete a key")
            keyException.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyException.fulfill()
      }
    }
    self.wait(for: [keyException], timeout: 10.0)
  }
}
