@testable import MeiliSearch
import XCTest

class SnapshotsTests: XCTestCase {
  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
  }

  func testCreateSnapshot() async throws {
    // Prepare the mock server

    let json = """
      { "taskUid": 278, "indexUid": null, "status": "enqueued", "type": "snapshotCreation", "enqueuedAt": "2022-07-21T21:43:12.419917471Z" }
    """

    let stubSnapshot: TaskInfo = try decodeJSON(from: json)
    session.pushData(json)

    // Start the test with the mocked server
    let snapshot = try await self.client.createSnapshot()
    XCTAssertEqual(stubSnapshot, snapshot)
  }
}
