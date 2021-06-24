@testable import MeiliSearch
import XCTest

class IndexesTests: XCTestCase {

    private var client: MeiliSearch!
    private let uid: String = "books_test"

    override func setUp() {
        super.setUp()

        if client == nil {
            client = try! MeiliSearch(hostURL: "http://localhost:7700", apiKey: "masterKey")
        }

        pool(client)

        let expectation = XCTestExpectation(description: "Try to delete index between tests")
        self.client.deleteIndex(UID: self.uid) { _ in
            expectation.fulfill()
        }
        self.wait(for: [expectation], timeout: 1.0)

    }

    func testCreateIndex() {

        let createExpectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                createExpectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [createExpectation], timeout: 1.0)
    }

    func testGetOrCreateIndex() {

        let expectation = XCTestExpectation(description: "Get or create Movies index")

        self.client.getOrCreateIndex(UID: uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get or create Movies index")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetOrCreateIndexAlreadyExists() {

        let expectation = XCTestExpectation(description: "Get or create a non existing uid")

        self.client.getOrCreateIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to get or create Movies index, error: \(error)")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

        sleep(2)

        let SecondExpectation = XCTestExpectation(description: "Get or create an existing index")

        self.client.getOrCreateIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                SecondExpectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to get or create an existing index, error: \(error)")
            }
        }

        self.wait(for: [SecondExpectation], timeout: 1.0)

    }

    func testGetIndex() {

        let expectation = XCTestExpectation(description: "Get or create a non existing uid")

        self.client.getOrCreateIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to get or create Movies index, error: \(error)")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

        let getIndexExpectation = XCTestExpectation(description: "Get index")

        self.client.getIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                getIndexExpectation.fulfill()
            case .failure:
                XCTFail("Failed to get index")
            }

        }

        self.wait(for: [getIndexExpectation], timeout: 1.0)

    }

    func testGetIndexes() {

        let CreateIndexExpectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                CreateIndexExpectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [CreateIndexExpectation], timeout: 1.0)

        sleep(1)

        let expectation = XCTestExpectation(description: "Load indexes")

        self.client.getIndexes { result in

            switch result {
            case .success(let indexes):
                let stubIndexes = [Index(UID: self.uid)]
                XCTAssertEqual(stubIndexes.count, indexes.count)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get all Indexes")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetEmptyIndexes() {

        let expectation = XCTestExpectation(description: "Load indexes")

        self.client.getIndexes { result in

            switch result {
            case .success(let indexes):
                XCTAssertEqual([], indexes)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get all Indexes")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testUpdateIndexName() {

        let createExpectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                createExpectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [createExpectation], timeout: 1.0)

        // This tests should tests primary key when they are added to this function
        let updateExpectation = XCTestExpectation(description: "Update movie index")
        self.client.updateIndex(UID: self.uid, primaryKey: "random") { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid, primaryKey: "random")
                XCTAssertEqual(stubIndex.primaryKey, index.primaryKey)
                XCTAssertEqual(stubIndex.UID, index.UID)
                updateExpectation.fulfill()
            case .failure:
                XCTFail("Failed to update movie index")
            }
        }
        self.wait(for: [updateExpectation], timeout: 1.0)
    }

    func testDeleteIndex() {

        let createExpectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(UID: self.uid) { result in
            switch result {
            case .success(let index):
                let stubIndex = Index(UID: self.uid)
                XCTAssertEqual(stubIndex.UID, index.UID)
                createExpectation.fulfill()
            case .failure:
                XCTFail("Failed to get Movies index")
            }
        }

        self.wait(for: [createExpectation], timeout: 1.0)

        let expectation = XCTestExpectation(description: "Delete Movies index")

        self.client.deleteIndex(UID: self.uid) { result in

            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to delete Movies index")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testCreateIndex", testCreateIndex),
        ("testGetOrCreateIndex", testGetOrCreateIndex),
        ("testGetOrCreateIndexAlreadyExists", testGetOrCreateIndexAlreadyExists),
        ("testGetIndex", testGetIndex),
        ("testGetIndexes", testGetIndexes),
        ("testGetEmptyIndexes", testGetEmptyIndexes),
        ("testUpdateIndexName", testUpdateIndexName),
        ("testDeleteIndex", testDeleteIndex)
    ]

}
