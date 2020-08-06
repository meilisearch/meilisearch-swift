@testable import MeiliSearch
import XCTest

class IndexesTests: XCTestCase {

    private var client: MeiliSearch!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: nil, session: session))
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

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Create Movies index")

        self.client.createIndex(UID: uid) { result in
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

    func testGetOrCreateIndex() {

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

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Get or create Movies index")

        self.client.getOrCreateIndex(UID: uid) { result in
            switch result {
            case .success(let index):
                XCTAssertEqual(stubIndex, index)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get or create Movies index")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetOrCreateIndexAlreadyExists() {

        //Prepare the mock server

        let createJsonString = """
        {"message":"Impossible to create index; index already exists","errorType":"invalid_request_error","errorCode":"index_already_exists"}
        """

        session.pushError(createJsonString, nil, code: 400)

        let getJsonString = """
        {
            "name":"Movies",
            "uid":"Movies",
            "createdAt":"2020-04-04T19:59:49.259572Z",
            "updatedAt":"2020-04-04T19:59:49.259579Z",
            "primaryKey":null
        }
        """

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = getJsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(getJsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Get or create Movies index")

        self.client.getOrCreateIndex(UID: uid) { result in
            switch result {
            case .success(let index):
                XCTAssertEqual(stubIndex, index)
                expectation.fulfill()
            case .failure(let error):
                XCTFail("Failed to get or create Movies index, error: \(error)")
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

        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let jsonData = jsonString.data(using: .utf8)!
        let stubIndex: Index = try! decoder.decode(Index.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Load Movies index")

        self.client.getIndex(UID: uid) { result in

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

        let decoder: JSONDecoder = JSONDecoder()
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

    func testDeleteIndex() {

        //Prepare the mock server

        session.pushEmpty(code: 204)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Delete Movies index")

        self.client.deleteIndex(UID: uid) { result in

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
