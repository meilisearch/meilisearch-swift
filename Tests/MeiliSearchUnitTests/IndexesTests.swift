@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class IndexesTests: XCTestCase {

  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testCreateIndex() {

    // Prepare the mock server

    let jsonString = """
      {
        "name":"Movies",
        "uid":"Movies",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    let jsonData = jsonString.data(using: .utf8)!

    let stubIndex: Index = try! Constants.customJSONDecoder.decode(Index.self, from: jsonData)

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let expectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(stubIndex.uid, index.uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetOrCreateIndex() {

    // Prepare the mock server

    let jsonString = """
      {
        "name":"Movies",
        "uid":"Movies",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let expectation = XCTestExpectation(description: "Get or create Movies index")

    self.client.getOrCreateIndex(uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(uid, index.uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get or create Movies index")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetIndex() {

    // Prepare the mock server

    let jsonString = """
      {
        "name":"Movies",
        "uid":"Movies",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }
      """

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let expectation = XCTestExpectation(description: "Load Movies index")

    self.client.getIndex(uid) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(uid, index.uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetIndexes() {

    // Prepare the mock server

    let jsonString = """
      [{
        "name":"Movies",
        "uid":"Movies",
        "createdAt":"2020-04-04T19:59:49.259572Z",
        "updatedAt":"2020-04-04T19:59:49.259579Z",
        "primaryKey":null
      }]
      """

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

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testUpdateIndex() {

    // Prepare the mock server

    let jsonString = """
      {
        "uid": "movie_review",
        "primaryKey": "movie_review_id",
        "createdAt": "2019-11-20T09:40:33.711324Z",
        "updatedAt": "2019-11-20T10:16:42.761858Z"
      }
      """

    session.pushData(jsonString)

    // Start the test with the mocked server

    let uid: String = "movies"
    let primaryKey: String = "movie_review_id"

    let expectation = XCTestExpectation(description: "Update Movies index")

    self.client.updateIndex(uid, primaryKey: primaryKey) { result in
      switch result {
      case .success(let index):
        XCTAssertEqual(uid, index.uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to update Movies index")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testDeleteIndex() {

    // Prepare the mock server

    session.pushEmpty(code: 204)

    // Start the test with the mocked server

    let uid: String = "Movies"

    let expectation = XCTestExpectation(description: "Delete Movies index")

    self.client.deleteIndex(uid) { result in

      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete Movies index")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  static var allTests = [
    ("testCreateIndex", testCreateIndex),
    ("testGetIndex", testGetIndex),
    ("testGetIndexes", testGetIndexes),
    ("testUpdateIndex", testUpdateIndex),
    ("testDeleteIndex", testDeleteIndex)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
