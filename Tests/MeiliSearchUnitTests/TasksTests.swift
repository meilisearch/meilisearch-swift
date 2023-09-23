@testable import MeiliSearch
import XCTest

// swiftlint:disable force_try
class TasksTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testGetTasksWithParametersFromClient() {
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

    self.client.getTasks(params: TasksQuery(limit: 20, from: 5, next: 98, types: ["indexCreation"])) { result in
      switch result {
      case .success:
        let requestQuery = self.session.nextDataTask.request?.url?.query

        XCTAssertEqual(requestQuery, "from=5&limit=20&next=98&types=indexCreation")

        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
