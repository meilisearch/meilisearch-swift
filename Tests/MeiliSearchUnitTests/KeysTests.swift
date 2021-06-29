@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
class KeysTests: XCTestCase {

  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch("http://localhost:7700", "masterKey", session)
  }

  func testKeys() {

    // Prepare the mock server

    let jsonString = """
      {
          "private": "8dcbb482663333d0280fa9fedf0e0c16d52185cb67db494ce4cd34da32ce2092",
          "public": "3b3bf839485f90453acc6159ba18fbed673ca88523093def11a9b4f4320e44a5"
      }
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubKey: Key = try! decoder.decode(Key.self, from: jsonData)

    session.pushData(jsonString)

    let expectation = XCTestExpectation(description: "Get public and private key")

    self.client.keys { result in
      switch result {
      case .success(let key):
        XCTAssertEqual(stubKey, key)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get public and private key")
      }
    }

    self.wait(for: [expectation], timeout: 1.0)
  }

  static var allTests = [
    ("testKeys", testKeys)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
