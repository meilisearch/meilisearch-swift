@testable import MeiliSearch
import XCTest

class StatsTests: XCTestCase {

    private var client: MeiliSearch!

    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: "", session: session))
    }

    func testStats() {

        //Prepare the mock server

        let jsonString = """
        {
            "numberOfDocuments": 19654,
            "isIndexing": false,
            "fieldsFrequency": {
                "poster": 19654,
                "release_date": 19654,
                "title": 19654,
                "id": 19654,
                "overview": 19654
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        let stubStats = try! Constants.customJSONDecoder.decode(Stat.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let expectation = XCTestExpectation(description: "Check Movies stats")

        self.client.stat(UID: uid) { result in
            switch result {
            case .success(let stats):
                XCTAssertEqual(stubStats, stats)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to check Movies stats")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testAllStats() {

        //Prepare the mock server

        let jsonString = """
        {
            "databaseSize": 447819776,
            "lastUpdate": "2019-11-15T11:15:22.092896Z",
            "indexes": {
                "movies": {
                    "numberOfDocuments": 19654,
                    "isIndexing": false,
                    "fieldsFrequency": {
                        "poster": 19654,
                        "overview": 19654,
                        "title": 19654,
                        "id": 19654,
                        "release_date": 19654
                    }
                },
                "rangemovies": {
                    "numberOfDocuments": 19654,
                    "isIndexing": false,
                    "fieldsFrequency": {
                        "overview": 19654,
                        "id": 19654,
                        "title": 19654
                    }
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!

        let stubAllStats = try! Constants.customJSONDecoder.decode(AllStats.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let expectation = XCTestExpectation(description: "Check all indexes stats")

        self.client.allStats { result in
            switch result {
            case .success(let allStats):
                XCTAssertEqual(stubAllStats, allStats)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to check all indexes stats")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testStats", testStats),
        ("testAllStats", testAllStats)
    ]
}
