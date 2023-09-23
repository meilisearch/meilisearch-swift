@testable import MeiliSearch
import XCTest

class IndexesTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testCreateIndex() {
    let jsonString = """
      {
        "taskUid": 0,
        "indexUid": "books",
        "status": "enqueued",
        "type": "indexCreation",
        "enqueuedAt": "2022-07-21T21:57:14.052648139Z"
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Create index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.taskUid)
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
      {
        "results": [
          {
            "uid": "movies",
            "createdAt": "2022-07-21T21:18:46.767583668Z",
            "updatedAt": "2022-07-21T21:47:50.583352169Z",
            "primaryKey": "id"
          },
        ],
        "offset": 0,
        "limit": 10,
        "total": 1
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Get indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        XCTAssertEqual("movies", indexes.results[0].uid)
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
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexUpdate","enqueuedAt":"2022-07-21T22:03:40.482534429Z"}
      """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.client.updateIndex(uid: self.uid, primaryKey: primaryKey) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.taskUid)
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
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexUpdate","enqueuedAt":"2022-07-21T22:03:40.482534429Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)
    let primaryKey: String = "movie_review_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update Movies index")

    self.index.update(primaryKey: primaryKey) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.taskUid)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update Movies index")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetIndexesWithParameters() {
    let jsonString = """
      {
        "results": [],
        "offset": 1,
        "limit": 9,
        "total": 0
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get indexes with parameters")

    self.client.getIndexes(params: IndexesQuery(limit: 9, offset: 1)) { result in
      switch result {
      case .success:
        XCTAssertEqual(self.session.nextDataTask.request?.url?.query, "limit=9&offset=1")

        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetTasksWithParametersFromIndex() {
    let jsonString = """
      {
        "results": [],
        "limit": 20,
        "from": 5,
        "next": 98,
        "total": 6
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get keys with parameters")

    self.index.getTasks(params: TasksQuery(limit: 20, from: 5, next: 98, types: [.indexCreation])) { result in
      switch result {
      case .success:
        let requestQuery = self.session.nextDataTask.request?.url?.query

        XCTAssertEqual(requestQuery, "from=5&indexUids=\(self.uid)&limit=20&next=98&types=indexCreation")
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteIndexWithClient() {
    let jsonString = """
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexDeletion","enqueuedAt":"2022-07-21T22:05:00.976623757Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete index with client instance")

    self.client.deleteIndex(self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.taskUid)
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
      {"taskUid":0,"indexUid":"books","status":"enqueued","type":"indexDeletion","enqueuedAt":"2022-07-21T22:05:00.976623757Z"}
    """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Delete index")

    self.index.delete { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(0, task.taskUid)
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
