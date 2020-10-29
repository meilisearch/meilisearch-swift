@testable import MeiliSearch
import XCTest

class SystemTests: XCTestCase {

    private var client: MeiliSearch!

    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: nil, session: session))
    }

    func testHealth() {

        //Prepare the mock server

        session.pushEmpty(code: 204)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Check server health")

        self.client.health { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to check server health")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testVersion() {

        //Prepare the mock server

        let jsonString = """
        {
            "commitSha": "b46889b5f0f2f8b91438a08a358ba8f05fc09fc1",
            "buildDate": "2019-11-15T09:51:54.278247+00:00",
            "pkgVersion": "0.1.1"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        let stubVersion: Version = try! Constants.customJSONDecoder.decode(Version.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Load server version")

        self.client.version { result in

            switch result {
            case .success(let version):
                XCTAssertEqual(stubVersion, version)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to load server version")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testHealth", testHealth),
        ("testVersion", testVersion)
    ]
}
