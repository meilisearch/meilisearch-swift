@testable import MeiliSearch
import XCTest

class UpdatesTests: XCTestCase {

    private var client: MeiliSearch!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(hostURL: "http://localhost:7700", session: session)
    }

    func testGetUpdate() {

        // Prepare the mock server

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

        let stubResult: Update.Result = try! Constants.customJSONDecoder.decode(
          Update.Result.self, from: data)

        session.pushData(json)

        // Start the test with the mocked server

        let UID: String = "movies"
        let update = Update(updateId: 1)

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getUpdate(UID: UID, update) { result in
            switch result {
            case .success(let result):
                XCTAssertEqual(stubResult, result)
            case .failure:
                XCTFail("Failed to get settings")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetUpdateInvalidStatus() {

        // Prepare the mock server

        let badStatusUpdateJson = """
        {
            "status": "something",
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

        session.pushData(badStatusUpdateJson)

        // Start the test with the mocked server

        let UID: String = "movies"
        let update = Update(updateId: 1)

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getUpdate(UID: UID, update) { result in
            switch result {
            case .success:
                XCTFail("The server send a invalid status and it should not succeed")
            case .failure(let error):
                XCTAssertTrue(error is Update.Status.StatusError)
                expectation.fulfill()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetAllUpdates() {

        // Prepare the mock server

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

        let stubResults: [Update.Result] = try! Constants.customJSONDecoder.decode([Update.Result].self, from: data)

        session.pushData(json)

        // Start the test with the mocked server

        let UID: String = "movies"

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getAllUpdates(UID: UID) { result in
            switch result {
            case .success(let results):
                XCTAssertEqual(stubResults, results)
            case .failure:
                XCTFail("Failed to get settings")
            }
            expectation.fulfill()
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testGetSetting", testGetUpdate),
        ("testGetAllUpdates", testGetAllUpdates)
    ]

}
