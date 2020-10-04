@testable import MeiliSearch
import XCTest

class ClientTests: XCTestCase {

  private let session = MockURLSession()

  func testValidHostURL() {
    session.pushEmpty(code: 200)
    XCTAssertNotNil(try? MeiliSearch(Config.default(apiKey: "masterKey", session: session)))
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
