@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_try
class KeysTests: XCTestCase {
  private var client: MeiliSearch!
  private var key: String = ""
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
        if keys.results.count > 0 {
          let key = keys.results.first
          if let firstKey: Key = key {
            self.key = firstKey.key
          }
        } else {
          XCTFail("Failed to get keys")
        }
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get keys")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
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
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
  }

  func testGetKey() {
    let keyExpectation = XCTestExpectation(description: "Get one key")

    self.client.getKey(key: self.key) { result in
      switch result {
      case .success(let key):
        XCTAssertNotNil(key.description)
        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get a key")
        keyExpectation.fulfill()
      }
    }
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
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

    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
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
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateKey() {
    let keyExpectation = XCTestExpectation(description: "Update a key")

    let keyParams = KeyParams(description: "Custom", name: "old name", actions: ["*"], indexes: ["index"], expiresAt: nil)
    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        let updateParams = KeyUpdateParams(description: "new name")
        self.client.updateKey(key: key.key, keyParams: updateParams) { result in
          switch result {
          case .success(let key):
            XCTAssertEqual(key.description, "new name")
            XCTAssertEqual(key.name, "old name")
            XCTAssertEqual(key.indexes, ["index"])
            XCTAssertNil(key.expiresAt)
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
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
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
    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
