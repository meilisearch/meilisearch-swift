@testable import MeiliSearch
import XCTest

class DocumentsTests: XCTestCase {

    private var client: Client!

    override func setUp() {
        super.setUp()
        client = Client(Config(hostURL: "http://localhost:7700", apiKey: ""))
    }
    
    func testCreateDocument() {

        let uid: String = "Movies"
        let documentString: String = ""
        let primaryKey: String = ""

        let document: Data = documentString.data(using: .utf8)!

        let expectation = XCTestExpectation(description: "Create Movies document")

        createIndex(named: uid) {

            self.client.createDocument(
                uid: uid, 
                document: document, 
                primaryKey: primaryKey) { result in
                expectation.fulfill()
            }

        }

        self.wait(for: [expectation], timeout: 10.0)

    }

    func testGetDocument() {

        let uid: String = "Movies"
        let identifier: String = ""

        let expectation = XCTestExpectation(description: "Get Movie document")

        createIndex(named: uid) {

            self.client.getDocument(uid: uid, identifier: identifier) { result in
                expectation.fulfill()
            }

        }

        self.wait(for: [expectation], timeout: 10.0)

    }

    func testGetDocuments() {

        let uid: String = "Movies"
        let limit: Int = 10

        let expectation = XCTestExpectation(description: "Create Movie documents")

        createIndex(named: uid) {
            self.client.getDocuments(uid: uid, limit: limit) { result in
                expectation.fulfill()
            }
        }

        self.wait(for: [expectation], timeout: 10.0)

    }

    // func testGetIndex() {
        
    //     let uid = "Movies"

    //     createIndex(named: uid) {

    //         let expectation = XCTestExpectation(description: "Load Movies index")

    //         self.client.getIndex(uid: uid) { result in
                
    //             switch result {
    //             case .success:
    //                 expectation.fulfill()
    //             case .failure:
    //                 XCTFail("Failed to get Movies index")
    //             }

    //         }

    //         self.wait(for: [expectation], timeout: 10.0)

    //     }

    // }

    // func testGetIndexes() {
    //     let uid = "Movies"

    //     createIndex(named: uid) {

    //         let expectation = XCTestExpectation(description: "Load indexes")

    //         self.client.getIndexes() { result in

    //             switch result {
    //             case .success:
    //                 expectation.fulfill()
    //             case .failure:
    //                 XCTFail("Failed to get all Indexes")
    //             }

    //         }

    //         self.wait(for: [expectation], timeout: 10.0)

    //     }

    // }
    
    // func testUpdateIndexName() {
    //     let uid = "Movies"
    //     let newUid = "Photos"

    //     createIndex(named: uid) {

    //         let expectation = XCTestExpectation(description: "Rename Movies to Photos")

    //         self.client.updateIndex(uid: uid, name: newUid) { result in
                
    //             switch result {
    //             case .success:
    //                 expectation.fulfill()
    //             case .failure:
    //                 XCTFail("Failed to update name of Movies index to Photos")
    //             }

    //         }

    //         self.wait(for: [expectation], timeout: 10.0)

    //     }

    // }

    // func testDeleteIndex() {
    //     let uid = "Movies"

    //     createIndex(named: uid) {

    //         let expectation = XCTestExpectation(description: "Rename Movies to Photos")

    //         self.client.deleteIndex(uid: uid) { result in

    //             switch result {
    //             case .success:
    //                 expectation.fulfill()
    //             case .failure:
    //                 XCTFail("Failed to delete Movies index")
    //             }

    //         }

    //         self.wait(for: [expectation], timeout: 10.0)

    //     }

    // }

    private func createIndex(named: String, _ completion: @escaping () -> Void) {
        self.client.createIndex(uid: named) { result in
            completion()
        }
    }
    
    static var allTests = [
        ("testCreateDocument", testCreateDocument),
        ("testGetDocument", testGetDocument),
        ("testGetDocuments", testGetDocuments),
        // ("testUpdateIndexName", testUpdateIndexName),
        // ("testDeleteIndex", testDeleteIndex),
    ]
}