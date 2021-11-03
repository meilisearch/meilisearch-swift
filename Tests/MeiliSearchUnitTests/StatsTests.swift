@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class StatsTests: XCTestCase {

  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index(self.uid)
  }

  func testStats() {

    let jsonString = """
      {
        "numberOfDocuments": 19654,
        "isIndexing": false,
        "fieldDistribution": {
          "poster": 19654,
          "release_date": 19654,
          "title": 19654,
          "id": 19654,
          "overview": 19654
        }
      }
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubStats: Stat = try! Constants.customJSONDecoder.decode(Stat.self, from: jsonData)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Check Movies stats")
    self.index.stats { result in
      switch result {
      case .success(let stats):
        XCTAssertEqual(stubStats, stats)
      case .failure:
        XCTFail("Failed to check Movies stats")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testAllStats() {

    let jsonString = """
      {
        "databaseSize": 447819776,
        "lastUpdate": "2019-11-15T11:15:22.092896Z",
        "indexes": {
          "movies": {
            "numberOfDocuments": 19654,
            "isIndexing": false,
            "fieldDistribution": {
              "poster": 19654,
              "overview": 19654,
              "title": 19654,
              "id": 19654,
              "release_date": 19654
            }
          },
          "rangemovies": {
            "numberOfDocuments": 19654,
            "isIndexing": false,
            "fieldDistribution": {
              "overview": 19654,
              "id": 19654,
              "title": 19654
            }
          }
        }
      }
      """
    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubAllStats: AllStats = try! Constants.customJSONDecoder.decode(AllStats.self, from: jsonData)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Check all indexes stats")

    self.client.allStats { result in
      switch result {
      case .success(let allStats):
        XCTAssertEqual(stubAllStats, allStats)
      case .failure:
        XCTFail("Failed to check all indexes stats")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
