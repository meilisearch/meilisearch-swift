@testable import MeiliSearch
import XCTest

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
        "uid": 0,
        "indexUid":"movies_test",
        "status": "succeeded",
        "type": "indexCreation",
        "enqueuedAt":"2020-04-04T19:59:49.259572Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Create index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
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
    let expectation = XCTestExpectation(description: "Get index with client instance")

    self.client.getIndex(uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get Movies index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
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
    let expectation = XCTestExpectation(description: "Get index")

    self.index.get { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(self.uid, index.uid)
        expectation.fulfill()
      case .failure(let error):
      dump(error)
        XCTFail("Failed to get Movies index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
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

    let expectation = XCTestExpectation(description: "Get indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        XCTAssertEqual("movies", indexes[0].uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateIndexWithClient() {
    let jsonString = """
      {"uid": 0, "indexUid": "movies_test", "status": "enqueued", "type": "documentAddition", "enqueuedAt": "xxx" }
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.client.updateIndex(uid: self.uid, primaryKey: primaryKey) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update Movies index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateIndex() {
    let jsonString = """
      {"uid": 0, "indexUid": "movies_test", "status": "enqueued", "type": "documentAddition", "enqueuedAt": "xxx" }
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.index.update(primaryKey: primaryKey) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update Movies index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteIndexWithClient() {
    let jsonString = """
    {
      "uid": 0,
      "indexUid":"movies_test",
      "status": "succeeded",
      "type": "indexDeletion",
      "enqueuedAt":"2020-04-04T19:59:49.259572Z"
    }
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete index with client instance")

    self.client.deleteIndex(self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteIndex() {
    let jsonString = """
    {
      "uid": 0,
      "indexUid":"movies_test",
      "status": "succeeded",
      "type": "indexDeletion",
      "enqueuedAt":"2020-04-04T19:59:49.259572Z"
    }
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete index")

    self.index.delete { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.uid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
