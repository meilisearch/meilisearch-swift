@testable import MeiliSearch
import XCTest

class ClientTests: XCTestCase {

  private let session = MockURLSession()

  func testValidHostURL() {
    session.pushEmpty(code: 200)
    XCTAssertNotNil(try? MeiliSearch(hostURL: "http://localhost:7700", apiKey: "masterKey", session: session))
  }

  func testWrongHostURL() {
    XCTAssertNotNil(try MeiliSearch(hostURL: "1234"))
  }

  func testNotValidHostURL() {
    XCTAssertThrowsError(try MeiliSearch(hostURL: "Not valid host")) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  static var allTests = [
      ("testValidHostURL", testValidHostURL),
      ("testWrongHostURL", testWrongHostURL),
      ("testNotValidHostURL", testNotValidHostURL)
  ]

}
