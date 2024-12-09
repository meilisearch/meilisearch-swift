@testable import MeiliSearch
import XCTest

class KeysTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testGetKeysWithParameters() async throws {
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
    _ = try await self.client.getKeys(params: KeysQuery(limit: 2, offset: 10))
    let requestQuery = self.session.nextDataTask.request?.url?.query
    XCTAssertEqual(requestQuery, "limit=2&offset=10")
  }
  
  func testEnumActions() {
    let key = Key(uid: "uid",
                  name: "name",
                  description: "some description",
                  key: "any",
                  actions: ["documents.add", "any-nonsupported-value"],
                  indexes: ["index1"],
                  expiresAt: nil,
                  createdAt: "2021-08-11T10:00:00Z",
                  updatedAt: "2021-08-11T10:00:00Z")
    
    XCTAssertEqual(key.enumActions, [.documentsAdd, .unknown("any-nonsupported-value")])
  }
}
