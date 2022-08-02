@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class DumpsTests: XCTestCase {
  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testCreateDump() {
    // Prepare the mock server

    let json = """
      { "taskUid": 278, "indexUid": null, "status": "enqueued", "type": "dumpCreation", "enqueuedAt": "2022-07-21T21:43:12.419917471Z" }
    """

    let data = json.data(using: .utf8)!

    let stubDump: TaskInfo = try! Constants.customJSONDecoder.decode(TaskInfo.self, from: data)

    session.pushData(json)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Create dump")

    self.client.createDump { result in
      switch result {
      case .success(let dump):
        XCTAssertEqual(stubDump, dump)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to create dump")
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
