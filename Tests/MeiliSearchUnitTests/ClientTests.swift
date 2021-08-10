@testable import MeiliSearch
import XCTest

// swiftlint:disable force_cast
class ClientTests: XCTestCase {

  private let session = MockURLSession()

  func testValidHostURL() {
    session.pushEmpty(code: 200)
    XCTAssertNotNil(try? MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session))
  }

  func testWrongHostURL() {
    XCTAssertNotNil(try MeiliSearch(host: "1234"))
  }

  func testNotValidHostURL() {
    XCTAssertThrowsError(try MeiliSearch(host: "Not valid host")) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  static var allTests = [
    ("testValidHostURL", testValidHostURL),
    ("testWrongHostURL", testWrongHostURL),
    ("testNotValidHostURL", testNotValidHostURL)
  ]

}
// swiftlint:enable force_cast
