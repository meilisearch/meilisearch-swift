import MeiliSearch
import XCTest

class DocumentsSortingTests: XCTestCase {
  func testGetDocumentsIncludesOrderedSortCriteria() async throws {
    let session = MockURLSession()
    session.pushData("""
      {"results":[],"offset":1,"limit":2,"total":0}
      """)
    let client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    let query = DocumentsQuery(limit: 2, offset: 1, fields: ["id", "title"], sort: ["title:asc", "id:desc"])
    let result: DocumentsResults<[String: String]> = try await client.index("books").getDocuments(params: query)
    XCTAssertTrue(result.results.isEmpty)
    let request = try XCTUnwrap(session.nextDataTask.request)
    XCTAssertEqual(request.httpMethod, "GET")
    XCTAssertEqual(request.url?.path, "/indexes/books/documents")
    let url = try XCTUnwrap(request.url)
    let items = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
    XCTAssertEqual(items.first { $0.name == "sort" }?.value, "title:asc,id:desc")
    XCTAssertEqual(items.first { $0.name == "limit" }?.value, "2")
    XCTAssertEqual(items.first { $0.name == "offset" }?.value, "1")
    XCTAssertEqual(items.first { $0.name == "fields" }?.value, "id,title")
  }

  func testGetDocumentsOmitsSortByDefault() async throws {
    let session = MockURLSession()
    session.pushData("""
      {"results":[],"offset":0,"limit":2,"total":0}
      """)
    let client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    let _: DocumentsResults<[String: String]> = try await client.index("books").getDocuments(params: DocumentsQuery(limit: 2))
    let url = try XCTUnwrap(session.lastURL)
    let items = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems)
    XCTAssertFalse(items.contains { $0.name == "sort" })
  }
}
