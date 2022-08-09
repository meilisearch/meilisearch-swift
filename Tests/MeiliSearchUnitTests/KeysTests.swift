@testable import MeiliSearch
import XCTest

// swiftlint:disable force_try
class KeysTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()

    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testGetKeysWithParameters() {
    let jsonString = """
      {
        "results": [],
        "offset": 10,
        "limit": 2,
        "total": 0
      }
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get keys with parameters")

    self.client.getKeys(params: KeysQuery(limit: 2, offset: 10)) { result in
      switch result {
      case .success:
        let requestQuery = self.session.nextDataTask.request?.url?.query

        XCTAssertEqual(requestQuery, "limit=2&offset=10")

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
