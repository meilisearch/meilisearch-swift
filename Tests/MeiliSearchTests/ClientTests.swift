@testable import MeiliSearch
import XCTest

class ClientTests: XCTestCase {

  private let session = MockURLSession()

  func testValidHostURL() {
    session.pushEmpty(code: 200)
    XCTAssertNotNil(try? MeiliSearch(Config(hostURL: "", session: session)))
  }

  func testEmptyHostURL() {
    session.pushError(nil, NSError(domain: "any", code: 404, userInfo: nil), code: 404)
    XCTAssertThrowsError(try MeiliSearch(Config(hostURL: "http://localhost:7700", session: session))) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.serverNotFound)
    }
  }

  func testNotValidHostURL() {
    session.pushError(nil, NSError(domain: "any", code: 404, userInfo: nil), code: 404)
    XCTAssertThrowsError(try MeiliSearch(Config(hostURL: "Not valid host", session: session))) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  static var allTests = [
      ("testValidHostURL", testValidHostURL),
      ("testEmptyHostURL", testEmptyHostURL)
  ]

}
