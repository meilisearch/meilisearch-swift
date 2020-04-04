@testable import MeiliSearch
import XCTest

class IndexesTests: XCTestCase {

    private var client: Client!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = Client(Config(hostURL: "http://localhost:7700", session: session))
    }

    func testCreateIndex() {

        //Prepare the mock server

        let jsonString = """
        {
            "name":"Movies",
            "uid":"Movies",
            "createdAt":"2020-04-04T19:59:49.259572Z",
            "updatedAt":"2020-04-04T19:59:49.259579Z",
            "primaryKey":null
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

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

        //Prepare the mock server

        let jsonString = """
        {
            "name":"Movies",
            "uid":"Movies",
            "createdAt":"2020-04-04T19:59:49.259572Z",
            "updatedAt":"2020-04-04T19:59:49.259579Z",
            "primaryKey":null
        }
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load Movies index")

        self.client.getIndex(uid: uid) { result in

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

    func testGetIndexes() {

        //Prepare the mock server

        let jsonString = """
        [{
            "name":"Movies",
            "uid":"Movies",
            "createdAt":"2020-04-04T19:59:49.259572Z",
            "updatedAt":"2020-04-04T19:59:49.259579Z",
            "primaryKey":null
        }]
        """

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndexes: [Index] = try! decoder.decode([Index].self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Load indexes")

        self.client.getIndexes { result in

            switch result {
            case .success(let indexes):
                XCTAssertEqual(stubIndexes, indexes)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get all Indexes")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    // func testUpdateIndexName() {

    //     //Prepare the mock server

    //     let jsonString = """
    //     [{
    //         "name":"Movies",
    //         "uid":"Movies",
    //         "createdAt":"2020-04-04T19:59:49.259572Z",
    //         "updatedAt":"2020-04-04T19:59:49.259579Z",
    //         "primaryKey":null
    //     }]
    //     """

    //     let decoder = JSONDecoder()
    //     decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
    //     let jsonData = jsonString.data(using: .utf8)!
    //     let stubIndexes: [Index] = try! decoder.decode([Index].self, from: jsonData)

    //     session.pushData(jsonString)

    //     // Start the test with the mocked server

    //     let uid: String = "Movies"
    //     let newUid: String = "Photos"

    //     let expectation = XCTestExpectation(description: "Rename Movies to Photos")

    //     self.client.updateIndex(uid: uid, name: newUid) { result in

    //         switch result {
    //         case .success:
    //             XCTAssertEqual(stubIndexes, indexes)
    //             expectation.fulfill()
    //         case .failure:
    //             XCTFail("Failed to rename Movies index to Photos")
    //         }

    //     }

    //     self.wait(for: [expectation], timeout: 1.0)

    // }

    func testDeleteIndex() {

        //Prepare the mock server

        session.pushEmpty(code: 204)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Delete Movies index")

        self.client.deleteIndex(uid: uid) { result in

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
        ("testGetIndex", testGetIndex),
        ("testGetIndexes", testGetIndexes),
        // ("testUpdateIndexName", testUpdateIndexName),
        ("testDeleteIndex", testDeleteIndex)
    ]
}
