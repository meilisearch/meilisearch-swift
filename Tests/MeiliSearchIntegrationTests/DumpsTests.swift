@testable import MeiliSearch
import XCTest
import Foundation

class DumpsTests: XCTestCase {

    private var client: MeiliSearch!
    private let uid: String = "books_test"

    // MARK: Setup

    override func setUp() {
        super.setUp()
        if client == nil {
            client = try! MeiliSearch("http://localhost:7700", "masterKey")
        }
        pool(client)
    }

    func testCreateAndGetDump() {

        let expectation = XCTestExpectation(description: "Request dump status")

        self.client.createDump { result in
            switch result {
            case .success(let createDump):

                XCTAssertTrue(!createDump.UID.isEmpty)

                self.client.getDumpStatus(UID: createDump.UID) { result in
                    switch result {
                    case .success(let dumpStatus):
                        XCTAssertEqual(createDump.UID, dumpStatus.UID)
                    case .failure(let error):
                        XCTFail("Failed to request dump status \(error)")
                    }
                    expectation.fulfill()
                }

            case .failure(let error):
                XCTFail("Failed to request dump creation \(error)")
                expectation.fulfill()
            }
        }

        self.wait(for: [expectation], timeout: 10.0)

    }

    static var allTests = [
        ("testCreateAndGetDump", testCreateAndGetDump)
    ]

}
