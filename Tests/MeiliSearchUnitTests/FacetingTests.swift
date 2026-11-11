@testable import MeiliSearch
import XCTest

class FacetingTests: XCTestCase {
  private let session = MockURLSession()
  private var index: Indexes!
  private let taskJSON = """
    {"taskUid":0,"indexUid":"books","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
    """

  override func setUpWithError() throws {
    try super.setUpWithError()
    let client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index("books")
  }

  func testGetFacetingSettings() async throws {
    session.pushData("""
      {"maxValuesPerFacet":100,"sortFacetValuesBy":{"*":"sampledCount","genres":"count","title":"alpha"}}
      """)
    let faceting = try await index.getFacetingSettings()
    XCTAssertEqual(faceting.maxValuesPerFacet, 100)
    XCTAssertEqual(faceting.sortFacetValuesBy, ["*": .sampledCount, "genres": .count, "title": .alpha])
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "GET")
    XCTAssertEqual(session.lastURL?.path, "/indexes/books/settings/faceting")
  }

  func testUpdateFacetingSettings() async throws {
    for sortOrder: [String: Faceting.SortOrder] in [
      ["*": .sampledCount], ["*": .alpha, "genres": .sampledCount]
    ] {
      session.pushData(taskJSON)
      let task = try await index.updateFacetingSettings(Faceting(sortFacetValuesBy: sortOrder))
      XCTAssertEqual(task.taskUid, 0)
      let request = try XCTUnwrap(session.nextDataTask.request)
      XCTAssertEqual(request.httpMethod, "PATCH")
      XCTAssertEqual(request.url?.path, "/indexes/books/settings/faceting")
      let body = try XCTUnwrap(request.httpBody)
      let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
      XCTAssertEqual(json["sortFacetValuesBy"] as? [String: String], sortOrder.mapValues { $0.rawValue })
      XCTAssertNil(json["maxValuesPerFacet"], "Partial updates must not overwrite the existing limit")
    }
  }

  func testResetFacetingSettings() async throws {
    session.pushData(taskJSON)
    let task = try await index.resetFacetingSettings()
    XCTAssertEqual(task.taskUid, 0)
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "DELETE")
    XCTAssertEqual(session.lastURL?.path, "/indexes/books/settings/faceting")
  }

  func testUpdateGlobalSettingsWithFaceting() async throws {
    session.pushData(taskJSON)
    _ = try await index.updateSettings(Setting(faceting: Faceting(sortFacetValuesBy: ["*": .sampledCount])))
    let body = try XCTUnwrap(session.nextDataTask.request?.httpBody)
    let json = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    let faceting = try XCTUnwrap(json["faceting"] as? [String: Any])
    XCTAssertEqual(faceting["sortFacetValuesBy"] as? [String: String], ["*": "sampledCount"])
  }
}
