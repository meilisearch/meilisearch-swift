@testable import MeiliSearch
import XCTest
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

class StatsTests: XCTestCase {
  private var client: MeiliSearch!
  private var session: URLSessionProtocol!
  private let uid: String = "stats_test"

  override func setUpWithError() throws {
    try super.setUpWithError()
    if client == nil {
      session = URLSession(configuration: .ephemeral)
      client = try MeiliSearch(host: currentHost(), apiKey: "masterKey", session: session)
    }
  }

  func testIndexStats() {
    let documentsExpectation = XCTestExpectation(description: "Add documents to index")
    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success:
        documentsExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        documentsExpectation.fulfill()
      }
    }
    self.wait(for: [documentsExpectation], timeout: TESTS_TIME_OUT)

    let statsExpectation = XCTestExpectation(description: "Get index stats")
    self.client.index(self.uid).stats { result in
      switch result {
      case .success(let stats):
        XCTAssertEqual(stats.numberOfDocuments, 1)
        // indexSize/usedIndexSize are only returned by Meilisearch v1.53.0+;
        // assert they decode without error and, when present, are sane byte counts.
        if let indexSize = stats.indexSize {
          XCTAssertGreaterThan(indexSize, 0)
        }
        if let usedIndexSize = stats.usedIndexSize {
          XCTAssertGreaterThan(usedIndexSize, 0)
        }
        statsExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get index stats")
        statsExpectation.fulfill()
      }
    }
    self.wait(for: [statsExpectation], timeout: TESTS_TIME_OUT)
  }

  func testAllStats() {
    let documentsExpectation = XCTestExpectation(description: "Add documents to index")
    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success:
        documentsExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        documentsExpectation.fulfill()
      }
    }
    self.wait(for: [documentsExpectation], timeout: TESTS_TIME_OUT)

    let statsExpectation = XCTestExpectation(description: "Get all stats")
    self.client.allStats { result in
      switch result {
      case .success(let allStats):
        let stat = allStats.indexes[self.uid]
        XCTAssertNotNil(stat)
        if let indexSize = stat?.indexSize {
          XCTAssertGreaterThan(indexSize, 0)
        }
        statsExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all stats")
        statsExpectation.fulfill()
      }
    }
    self.wait(for: [statsExpectation], timeout: TESTS_TIME_OUT)
  }
}
