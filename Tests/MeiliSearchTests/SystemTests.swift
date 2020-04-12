@testable import MeiliSearch
import XCTest

class SystemTests: XCTestCase {

    private var client: MeiliSearch!

    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: "", session: session))
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

    func testUpdateHealth() {

        //Prepare the mock server

        session.pushEmpty(code: 204)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Check server health")

        self.client.updateHealth(health: true) { result in
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

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubVersion: Version = try! decoder.decode(Version.self, from: jsonData)

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

    func testSystemInfo() {

        //Prepare the mock server

        let jsonString = """
        {
            "memoryUsage": 55.85753917694092,
            "processorUsage": [
                0,
                25.039959,
                4.4766316,
                20.698938,
                3.9757106,
                18.126263,
                3.6868486,
                14.838916,
                3.4483202
            ],
            "global": {
                "totalMemory": 16777216,
                "usedMemory": 9371340,
                "totalSwap": 4194304,
                "usedSwap": 2519552,
                "inputData": 29817185280,
                "outputData": 4216431616
            },
            "process": {
                "memory": 4112,
                "cpu": 0
            }
        }
        """

        let decoder: JSONDecoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        let stubSystemInfo: SystemInfo = try! decoder.decode(SystemInfo.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Load system info")

        self.client.systemInfo { result in

            switch result {
            case .success(let systemInfo):
                XCTAssertEqual(stubSystemInfo, systemInfo)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to load system info")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testPrettySystemInfo() {

        //Prepare the mock server

        let jsonString = """
        {
            "memoryUsage": "56.3 %",
            "processorUsage": [
                "0.0 %",
                "25.0 %",
                "4.5 %",
                "20.7 %",
                "4.0 %",
                "18.1 %",
                "3.7 %",
                "14.8 %",
                "3.4 %"
            ],
            "global": {
                "totalMemory": "17.18 GB",
                "usedMemory": "9.67 GB",
                "totalSwap": "4.29 GB",
                "usedSwap": "2.58 GB",
                "inputData": "29.82 GB",
                "outputData": "4.22 GB"
            },
            "process": {
                "memory": "5.2 MB",
                "cpu": "0.0 %"
            }
        }
        """

        let decoder: JSONDecoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        let stubPrettySystemInfo: PrettySystemInfo =
          try! decoder.decode(PrettySystemInfo.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Load pretty system info")

        self.client.prettySystemInfo { result in

            switch result {
            case .success(let prettySystemInfo):
                XCTAssertEqual(stubPrettySystemInfo, prettySystemInfo)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to load pretty system info")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testHealth", testHealth),
        ("testUpdateHealth", testUpdateHealth),
        ("testVersion", testVersion),
        ("testSystemInfo", testSystemInfo),
        ("testPrettySystemInfo", testPrettySystemInfo)
    ]
}
