@testable import MeiliSearch
import XCTest

class IndexesTests: XCTestCase {

    private var client: Client!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = Client(
            Config(hostURL: "http://localhost:7700", session: session))
    }
    
    func testCreateIndex() {

        let jsonString = """
        {
            "name":"Movies",
            "uid":"Movies",
            "createdAt":"2020-04-04T19:59:49.259572Z",
            "updatedAt":"2020-04-04T19:59:49.259579Z",
            "primaryKey":null}
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(uid: uid) { result in
            switch result {
            case .success(let index):
                XCTAssertEqual(stubIndex, index)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetIndex() {
        
        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load Movies index")

        createIndex(uid: uid) {

            self.client.getIndex(uid: uid) { result in
                
                switch result {
                case .success(let index):
                    // XCTAssertEqual(stub, index)
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to get Movies index")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetIndexes() {

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load indexes")

        createIndex(uid: uid) {

            self.client.getIndexes() { result in

                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to get all Indexes")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }
    
    func testUpdateIndexName() {

        let uid: String = "Movies"
        let newUid: String = "Photos"

        let expectation = XCTestExpectation(description: "Rename Movies to Photos")

        createIndex(uid: uid) {

            self.client.updateIndex(uid: uid, name: newUid) { result in
                
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to rename Movies index to Photos")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testDeleteIndex() {

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Delete Movies index")

        createIndex(uid: uid) {

            self.client.deleteIndex(uid: uid) { result in

                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to delete Movies index")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testDeleteAllIndexes() {

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Delete Movies indexes")

        createIndex(uid: uid) {

            self.client.deleteAllIndexes { result in

                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to delete Movies indexes")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    private func createIndex(uid: String, _ completion: @escaping () -> Void) {
        self.client.createIndex(uid: uid) { result in
            completion()
        }
    }
    
    static var allTests = [
        ("testCreateIndex", testCreateIndex),
        ("testGetIndex", testGetIndex),
        ("testGetIndexes", testGetIndexes),
        ("testUpdateIndexName", testUpdateIndexName),
        ("testDeleteIndex", testDeleteIndex),
        ("testDeleteAllIndexes", testDeleteAllIndexes),
    ]
}