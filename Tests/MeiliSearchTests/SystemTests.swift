@testable import MeiliSearch
import XCTest

class SystemTests: XCTestCase {

    private var client: Client!

    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = Client(Config(hostURL: "http://localhost:7700"))
    }
    
    func testHealth() {

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Check server health")

        self.client.health { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testVersion() {
        
        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load Movies index")

        self.client.version { result in
            
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testSystemInfo() {

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load indexes")

        self.client.sysInfo { result in

            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get all Indexes")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }
    
    static var allTests = [
        ("testHealth", testHealth),
        ("testVersion", testVersion),
        ("testSystemInfo", testSystemInfo),
    ]
}