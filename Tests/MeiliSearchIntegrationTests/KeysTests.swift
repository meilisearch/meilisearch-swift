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
    let keyExpectation = XCTestExpectation(description: "Get all keys")

    self.client.getKeys { result in
      switch result {
      case .success(let keys):
        self.key = keys.results.first
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get keys")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testGetKeys() {
    let keyExpectation = XCTestExpectation(description: "Get all keys")

    self.client.getKeys { result in
      switch result {
      case .success(let keys):
        XCTAssertNotEqual(keys.results.count, 0)
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all keys")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testGetKey() {
    let keyExpectation = XCTestExpectation(description: "Get one key")

    self.client.getKey(key: self.key.key) { result in
      switch result {
      case .success(let key):
        if key !== nil {
          XCTAssertNotNil(key.description)
        } else {
          XCTFail("Key does not exist")
        }
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get a key")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testCreateKey() {
    let keyExpectation = XCTestExpectation(description: "Create a key")

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        XCTAssertEqual(key.expiresAt, nil)
        XCTAssertEqual(key.description, keyParams.description)
        XCTAssertEqual(key.actions, keyParams.actions)
        XCTAssertEqual(key.indexes, keyParams.indexes)
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyExpectation.fulfill()
      }
    }

    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testCreateKeyWithExpire() {
    let keyExpectation = XCTestExpectation(description: "Create a key with an expireAt value")

    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let someDateTime = formatter.string(from: Date.distantFuture)

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: someDateTime)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        XCTAssertEqual(key.description, keyParams.description)
        XCTAssertEqual(key.actions, keyParams.actions)
        XCTAssertEqual(key.indexes, keyParams.indexes)
        XCTAssertNotNil(key.expiresAt)
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testUpdateKey() {
    let keyExpectation = XCTestExpectation(description: "Update a key")

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
            XCTAssertEqual(key.description, keyParams.description)
            XCTAssertEqual(key.actions, keyParams.actions)
            XCTAssertEqual(key.indexes, keyParams.indexes)
            XCTAssertNotNil(key.expiresAt)
            keyExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to update a key")
            keyExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }

  func testDeleteKey() {
    let keyExpectation = XCTestExpectation(description: "Delete a key")

    let keyParams = KeyParams(description: "Custom", actions: ["*"], indexes: ["*"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        self.client.deleteKey(key: key.key) { result in
          switch result {
          case .success:
            self.client.getKey(key: key.key) { result in
              switch result {
              case .success(let key):
                XCTAssertNotNil(key.description)
                XCTFail("Failed to get a key")
                keyExpectation.fulfill()
              case .failure(let error as MeiliSearch.Error):
                switch error {
                case MeiliSearch.Error.meiliSearchApiError(_, let msErrorResponse, _, _):
                  if let msError: MeiliSearch.MSErrorResponse = msErrorResponse {
                    XCTAssertEqual(msError.code, "api_key_not_found")
                  } else {
                    XCTFail("Failed to get the correct error code")
                  }
                default:
                  dump(error)
                  XCTFail("Failed to delete the key")
                }
                keyExpectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to get the correct error type")
                keyExpectation.fulfill()
              }
            }
          case .failure(let error):
            dump(error)
            XCTFail("Failed to delete a key")
            keyExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: 10.0)
  }
}
