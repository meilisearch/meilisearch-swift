@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class IndexesTests: XCTestCase {

  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testCreateIndex() {

    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
      case .failure:
        XCTFail("Failed to get Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetOrCreateIndex() {

    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """
    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get or create Movies index")

    self.client.getOrCreateIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
      case .failure:
        XCTFail("Failed to get or create Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetIndexWithClient() {

    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Load Movies index")

    self.client.getIndex(uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
      case .failure:
        XCTFail("Failed to get Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetIndex() {

    let jsonString = """
      {
        "name":"Movies",
        "uid":"movies_test",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Load Movies index")

    self.index.get { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
      case .failure:
        XCTFail("Failed to get Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetIndexes() {
    let jsonString = """
      [{
        "name":"movies",
        "uid":"movies",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Load indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        XCTAssertEqual("movies", indexes[0].uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get all Indexes")
      }

    }

    self.wait(for: [expectation], timeout: 10.0)

  }

func testUpdateIndexWithClient() {

    let jsonString = """
      {
        "uid": "movies_test",
        "primaryKey": "movie_review_id",
        "createdAt": "2019-11-20T09:40:33.711324Z",
        "updatedAt": "2019-11-20T10:16:42.761858Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.client.updateIndex(uid: self.uid, primaryKey: primaryKey) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
        XCTAssertEqual(primaryKey, index.primaryKey)
      case .failure:
        XCTFail("Failed to update Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testUpdateIndex() {

    let jsonString = """
      {
        "uid": "movies_test",
        "primaryKey": "movie_review_id",
        "createdAt": "2019-11-20T09:40:33.711324Z",
        "updatedAt": "2019-11-20T10:16:42.761858Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.index.update(primaryKey: primaryKey) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
        XCTAssertEqual(primaryKey, index.primaryKey)
      case .failure:
        XCTFail("Failed to update Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testDeleteIndexWithClient() {

    // Prepare the mock server
    session.pushEmpty(code: 204)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete Movies index")

    self.client.deleteIndex(self.uid) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testDeleteIndex() {

    // Prepare the mock server
    session.pushEmpty(code: 204)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete Movies index")

    self.index.delete { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete Movies index")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
