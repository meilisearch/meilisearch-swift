@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_try
class KeysTests: XCTestCase {
  private var client: MeiliSearch!
  private var session: URLSessionProtocol!

  // MARK: Setup

  override func setUp() {
    super.setUp()

    session = URLSession(configuration: .ephemeral)
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)

    // remove all keys to keep a clean state
    self.client.getKeys(params: KeysQuery(limit: 100, offset: 0)) { result in
      switch result {
      case .success(let keys):
        keys.results.forEach {
          self.client.deleteKey(key: $0.uid) { result in
            switch result {
            case .success:
              ()
            case .failure(let error):
              dump(error)
              XCTFail("Failed to delete key")
            }
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to retrieve and delete all keys")
      }
    }
  }

  func testGetKeys() {
    let keyExpectation = XCTestExpectation(description: "Get a list of keys")

    self.client.createKey(KeyParams(actions: ["*"], indexes: ["*"], expiresAt: nil)) { result in
      switch result {
      case .success:
        self.client.getKeys { result in
          switch result {
          case .success(let keys):
            XCTAssertNotEqual(keys.results.count, 0)
          case .failure(let error):
            dump(error)
            XCTFail("Failed to get all keys")
          }
        }

        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
        keyExpectation.fulfill()
      }
    }

    self.wait(for: [keyExpectation], timeout: TESTS_TIME_OUT)
  }

  func testGetKey() {
    let keyExpectation = XCTestExpectation(description: "Get one key")

    self.client.createKey(KeyParams(actions: ["*"], indexes: ["*"], expiresAt: nil)) { result in
      switch result {
      case .success(let createdKey):
        self.client.getKey(keyOrUid: createdKey.uid) { result in
          switch result {
          case .success(let fetchedKey):
            XCTAssertEqual(fetchedKey.expiresAt, nil)
            XCTAssertEqual(fetchedKey.description, createdKey.description)
            XCTAssertEqual(fetchedKey.actions, createdKey.actions)
            XCTAssertEqual(fetchedKey.indexes, createdKey.indexes)
            XCTAssertEqual(fetchedKey.uid, createdKey.uid)
          case .failure(let error):
            dump(error)
            XCTFail("Failed to get key by uid \(createdKey.uid)")
          }
        }

        keyExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create a key")
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

  func testCreateKeyWithOptionalUid() {
    let keyExpectation = XCTestExpectation(description: "Create a key")
    let uid = "1f05fa47-cfa6-40f7-8b80-7bd17b39f105"
    let keyParams = KeyParams(uid: uid, actions: ["*"], indexes: ["*"], expiresAt: nil)

    self.client.createKey(keyParams) { result in
      switch result {
      case .success(let key):
        XCTAssertEqual(key.expiresAt, nil)
        XCTAssertEqual(key.uid, uid)
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
            self.client.getKey(keyOrUid: key.key) { result in
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
