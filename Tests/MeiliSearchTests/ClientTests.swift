@testable import MeiliSearch
import XCTest

class ClientTests: XCTestCase {

  func testValidHostURL() {
    let client: MeiliSearch = try! MeiliSearch(Config(hostURL: "http://localhost:7700", apiKey: "masterKey"))
    XCTAssertNotNil(try? MeiliSearch(Config(hostURL: "http://localhost:7700", apiKey: "masterKey")))
  }

  func testEmptyHostURL() {
    XCTAssertThrowsError(try MeiliSearch(Config(hostURL: "http://localhost:1234"))) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.serverNotFound)
    }
  }

  func testNotValidHostURL() {
    XCTAssertThrowsError(try MeiliSearch(Config(hostURL: "Not valid host"))) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  static var allTests = [
      ("testValidHostURL", testValidHostURL),
      ("testEmptyHostURL", testEmptyHostURL)
  ]

}
