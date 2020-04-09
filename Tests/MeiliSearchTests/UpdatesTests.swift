@testable import MeiliSearch
import XCTest

class UpdatesTests: XCTestCase {

    private var client: MeiliSearch!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: "", session: session))
    }

    func testGetUpdate() {

        //Prepare the mock server

        let json = """
        {
            "status": "processed",
            "updateId": 1,
            "type": {
                "name": "DocumentsAddition",
                "number": 4
            },
            "duration": 0.076980613,
            "enqueuedAt": "2019-12-07T21:16:09.623944Z",
            "processedAt": "2019-12-07T21:16:09.703509Z"
        }
        """

        let data = json.data(using: .utf8)!
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let stubResult: Update.Result = try! decoder.decode(Update.Result.self, from: data)

        session.pushData(json)

        // Start the test with the mocked server

        let UID: String = "movies"
        let update = Update(updateId: 1)

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getUpdate(UID: UID, update) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(stubResult, result)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get settings")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetAllUpdates() {

        //Prepare the mock server

        let json = """
        [
            {
                "status": "processed",
                "updateId": 1,
                "type": {
                    "name": "DocumentsAddition",
                    "number": 4
                },
                "duration": 0.076980613,
                "enqueuedAt": "2019-12-07T21:16:09.623944Z",
                "processedAt": "2019-12-07T21:16:09.703509Z"
            }
        ]
        """

        let data = json.data(using: .utf8)!
        let decoder: JSONDecoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        let stubResults: [Update.Result] = try! decoder.decode([Update.Result].self, from: data)

        session.pushData(json)

        // Start the test with the mocked server

        let UID: String = "movies"

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getAllUpdates(UID: UID) { result in
            switch result {
            case .success(let results):
                XCTAssertEqual(stubResults, results)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get settings")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testGetSetting", testGetUpdate),
        ("testGetAllUpdates", testGetAllUpdates)
    ]

}
