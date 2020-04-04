@testable import MeiliSearch
import XCTest

class DocumentsTests: XCTestCase {

    private var client: Client!

    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = Client(Config(hostURL: "http://localhost:7700"))
    }
    
    func testCreateDocument() {

        let uid: String = "Movies"
        let documentString: String = ""
        let primaryKey: String = ""

        let document: Data = documentString.data(using: .utf8)!

        let expectation = XCTestExpectation(description: "Create Movies document")

        createIndex(uid: uid) {

            self.client.createDocument(
                uid: uid, 
                document: document, 
                primaryKey: primaryKey) { result in
                
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to create Movies document")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetDocument() {

        let uid: String = "Movies"
        let identifier: String = ""

        let expectation = XCTestExpectation(description: "Get Movies document")

        createIndex(uid: uid) {

            self.client.getDocument(uid: uid, identifier: identifier) { result in
                
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to get Movies document")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetDocuments() {

        let uid: String = "Movies"
        let limit: Int = 10

        let expectation = XCTestExpectation(description: "Get Movies documents")

        createIndex(uid: uid) {

            self.client.getDocuments(uid: uid, limit: limit) { result in
                
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to get Movies documents")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testDeleteDocument() {

        let uid = "Movies"
        let identifier: String = ""

        let expectation = XCTestExpectation(description: "Delete Movies document")

        createIndex(uid: uid) {

            self.client.deleteDocument(uid: uid, identifier: identifier) { result in

                switch result {
                case .success:
                    expectation.fulfill()
                case .failure:
                    XCTFail("Failed to delete Movies document")
                }

            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testDeleteAllDocuments() {

        let uid = "Movies"
        let expectation = XCTestExpectation(description: "Delete all Movies documents")

        createIndex(uid: uid) {

            self.createDocument(uid: uid) {

                self.client.deleteAllDocuments(uid: uid) { result in

                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure:
                        XCTFail("Failed to delete all Movies documents")
                    }

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

    private func createDocument(uid: String, _ completion: @escaping () -> Void) {
        let documentString: String = ""
        let document: Data = documentString.data(using: .utf8)!
        let primaryKey: String = ""
        self.client.createDocument(
                uid: uid, 
                document: document, 
                primaryKey: primaryKey) { result in
            completion()
        }
    }
    
    static var allTests = [
        ("testCreateDocument", testCreateDocument),
        ("testGetDocument", testGetDocument),
        ("testGetDocuments", testGetDocuments),
        ("testDeleteDocument", testDeleteDocument),
        ("testDeleteAllDocuments", testDeleteAllDocuments),
    ]
}