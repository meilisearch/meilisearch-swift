@testable import MeiliSearch
import XCTest

class TasksTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testGetTaskDocumentsFromClient() async throws {
    let ndjsonString = """
    {"id":1,"title":"Movie 1"}
    {"id":2,"title":"Movie 2"}
    """

    struct SimpleDoc: Decodable, Equatable {
      let id: Int
      let title: String
    }

    session.pushData(ndjsonString)

    let documents: [SimpleDoc] = try await self.client.getTaskDocuments(taskUid: 1)

    XCTAssertEqual(documents.count, 2)
    XCTAssertEqual(documents[0].id, 1)
    XCTAssertEqual(documents[0].title, "Movie 1")
    XCTAssertEqual(documents[1].id, 2)
    XCTAssertEqual(documents[1].title, "Movie 2")

    let requestPath = self.session.nextDataTask.request?.url?.path
    XCTAssertEqual(requestPath, "/tasks/1/documents")
  }

  func testGetTaskDocumentsEmptyResponse() async throws {
    session.pushData("")

    struct SimpleDoc: Decodable, Equatable {
      let id: Int
    }

    let documents: [SimpleDoc] = try await self.client.getTaskDocuments(taskUid: 1)

    XCTAssertEqual(documents.count, 0)
  }

  func testGetTaskDocumentsMalformedResponse() async throws {
    session.pushData("""
    {"id":1}
    not-json
    """)

    struct SimpleDoc: Decodable { let id: Int }

    do {
      let _: [SimpleDoc] = try await self.client.getTaskDocuments(taskUid: 1)
      XCTFail("Expected decoding to fail")
    } catch {
      XCTAssertNotNil(error)
    }
  }

  func testGetTasksWithParametersFromClient() async throws {
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
    let params = TasksQuery(limit: 20, from: 5, next: 98, types: [.indexCreation])
    _ = try await self.client.getTasks(params: params)

    let requestQuery = self.session.nextDataTask.request?.url?.query
    XCTAssertEqual(requestQuery, "from=5&limit=20&next=98&types=indexCreation")
  }
}
