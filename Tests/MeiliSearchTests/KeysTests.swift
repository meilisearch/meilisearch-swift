@testable import MeiliSearch
import XCTest

class KeysTests: XCTestCase {

    private var client: MeiliSearch!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: nil, session: session))
    }

    func testKeys() {

        //Prepare the mock server

        let jsonString = """
        {
            "private": "8c222193c4dff5a19689d637416820bc623375f2ad4c31a2e3a76e8f4c70440d",
            "public": "948413b6667024a0704c2023916c21eaf0a13485a586c43e4d2df520852a4fb8"
        }
        """

        let decoder: JSONDecoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        let stubKey: Key = try! decoder.decode(Key.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let masterKey = "c4dff5a196824a0704c2023916c21eaf0a13485a9d637416820bc623375f2a"

        let expectation = XCTestExpectation(description: "Get public and private key")

      self.client.keys(masterKey: masterKey) { result in
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
