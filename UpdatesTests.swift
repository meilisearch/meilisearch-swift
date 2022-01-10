@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class UpdatesTests: XCTestCase {

  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  func testGetUpdate() {
    let json = """
      {
        "status": "processed",
        "updateId": 1,
        "type": {
          "name": "DocumentsAddition",
          "number": 4
        },
        "duration": 0.076980613,
        "enqueuedAt": "2019-12-07T21:16:09.623944Z",
        "processedAt": "2019-12-07T21:16:09.703509Z"
      }
      """
    // Prepare the mock server
    let data = json.data(using: .utf8)!
    let stubResult: Task.Result = try! Constants.customJSONDecoder.decode(
      Task.Result.self, from: data)
    session.pushData(json)

    // Start the test with the mocked server
    let update = Update(updateId: 1)
    let expectation = XCTestExpectation(description: "Get settings")
    self.index.getUpdate(update.updateId) { result in
      switch result {
      case .success(let result):
        XCTAssertEqual(stubResult, result)
      case .failure:
        XCTFail("Failed to get settings")
      }
      expectation.fulfill()
    }
    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetUpdateInvalidStatus() {

    let badStatusUpdateJson = """
      {
        "status": "something",
        "updateId": 1,
        "type": {
          "name": "DocumentsAddition",
          "number": 4
        },
        "duration": 0.076980613,
        "enqueuedAt": "2019-12-07T21:16:09.623944Z",
        "processedAt": "2019-12-07T21:16:09.703509Z"
      }
      """
    // Prepare the mock server
    session.pushData(badStatusUpdateJson)

    // Start the test with the mocked server
    let update = Update(updateId: 1)
    let expectation = XCTestExpectation(description: "Get settings")
    self.index.getUpdate(update.updateId) { result in
      switch result {
      case .success:
        XCTFail("The server send a invalid status and it should not succeed")
      case .failure(let error):
        XCTAssertTrue(error is Task.Status.StatusError)
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testGetAllUpdates() {

    let json = """
      [
        {
          "status": "processed",
          "updateId": 1,
          "type": {
            "name": "DocumentsAddition",
            "number": 4
          },
          "duration": 0.076980613,
          "enqueuedAt": "2019-12-07T21:16:09.623944Z",
          "processedAt": "2019-12-07T21:16:09.703509Z"
        }
      ]
      """
    // Prepare the mock server
    let data = json.data(using: .utf8)!
    let stubResults: [Task.Result] = try! Constants.customJSONDecoder.decode([Task.Result].self, from: data)
    session.pushData(json)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get settings")

    self.index.getAllUpdates { result in
      switch result {
      case .success(let results):
        XCTAssertEqual(stubResults, results)
      case .failure:
        XCTFail("Failed to get settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
