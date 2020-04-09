@testable import MeiliSearch
import XCTest

class SettingsTests: XCTestCase {

    private var client: MeiliSearch!
    private let session = MockURLSession()

    private let json = """
    {
        "rankingRules": [
            "typo",
            "words",
            "proximity",
            "attribute",
            "wordsPosition",
            "exactness",
            "desc(release_date)"
        ],
        "distinctAttribute": null,
        "searchableAttributes": ["title", "description", "uid"],
        "displayedAttributes": [
            "title",
            "description",
            "release_date",
            "rank",
            "poster"
        ],
        "stopWords": null,
        "synonyms": {
            "wolverine": ["xmen", "logan"],
            "logan": ["wolverine", "xmen"]
        },
        "acceptNewFields": false
    }
    """

    override func setUp() {
        super.setUp()
        client = try! MeiliSearch(Config(hostURL: "", session: session))
    }

    func testGetSetting() {

        //Prepare the mock server

        let stubSetting: Setting = buildStubSetting()

        session.pushData(json)

        // Start the test with the mocked server

        let UID: String = "movies"

        let expectation = XCTestExpectation(description: "Get settings")

        self.client.getSetting(UID: UID) { result in
            switch result {
            case .success(let setting):
                XCTAssertEqual(stubSetting, setting)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get settings")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testUpdateSetting() {

        //Prepare the mock server

        let jsonString = """
        {"updateId":0}
        """

        let decoder: JSONDecoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let UID: String = "movies"
        let setting: Setting = buildStubSetting()

        let expectation = XCTestExpectation(description: "Update settings")

        self.client.updateSetting(UID: UID, setting) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(stubUpdate, update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to update settings")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testResetSetting() {

        //Prepare the mock server

        let jsonString = """
        {"updateId":0}
        """

        let decoder: JSONDecoder = JSONDecoder()
        let data: Data = jsonString.data(using: .utf8)!
        let stubUpdate: Update = try! decoder.decode(Update.self, from: data)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let UID: String = "movies"

        let expectation = XCTestExpectation(description: "Reset settings")

        self.client.resetSetting(UID: UID) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(stubUpdate, update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to reset settings")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testGetSynonyms() {

        //Prepare the mock server

        let jsonString = """
        {
            "wolverine": ["xmen", "logan"],
            "logan": ["wolverine", "xmen"],
            "wow": ["world of warcraft"]
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let stubSynonyms: [String: [String]] = try! JSONSerialization.jsonObject(
          with: jsonData, options: []) as! [String: [String]]

        session.pushData(jsonString)

        // Start the test with the mocked server

        let UID: String = "movies"

        let expectation = XCTestExpectation(description: "Get synonyms")

        self.client.getSynonyms(UID: UID) { result in
            switch result {
            case .success(let synonyms):
                XCTAssertEqual(stubSynonyms, synonyms)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to get synonyms")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testUpdateSynonyms() {

        //Prepare the mock server

        let jsonString = """
        {"updateId":0}
        """

        let decoder: JSONDecoder = JSONDecoder()
        let stubUpdate: Update = try! decoder.decode(
          Update.self,
          from: jsonString.data(using: .utf8)!)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let UID: String = "movies"

        let json = """
        {
            "wolverine": ["xmen", "logan"],
            "logan": ["wolverine", "xmen"],
            "wow": ["world of warcraft"]
        }
        """

        let jsonData = json.data(using: .utf8)!
        let synonyms: [String: [String]] = try! JSONSerialization.jsonObject(
          with: jsonData, options: []) as! [String: [String]]

        let expectation = XCTestExpectation(description: "Update synonyms")

        self.client.updateSynonyms(UID: UID, synonyms) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(stubUpdate, update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to update synonyms")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    func testResetSynonyms() {

        //Prepare the mock server

        let jsonString = """
        {"updateId":0}
        """

        let decoder: JSONDecoder = JSONDecoder()
        let stubUpdate: Update = try! decoder.decode(
          Update.self,
          from: jsonString.data(using: .utf8)!)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let UID: String = "movies"

        let json = """
        {
            "wolverine": ["xmen", "logan"],
            "logan": ["wolverine", "xmen"],
            "wow": ["world of warcraft"]
        }
        """

        let jsonData = json.data(using: .utf8)!
        let synonyms: [String: [String]] = try! JSONSerialization.jsonObject(
          with: jsonData, options: []) as! [String: [String]]

        let expectation = XCTestExpectation(description: "Reset synonyms")

        self.client.updateSynonyms(UID: UID, synonyms) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(stubUpdate, update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to reset synonyms")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    private func buildStubSetting() -> Setting {
        let data = json.data(using: .utf8)!
        let decoder: JSONDecoder = JSONDecoder()
        return try! decoder.decode(Setting.self, from: data)
    }

    static var allTests = [
        ("testGetSetting", testGetSetting),
        ("testUpdateSetting", testUpdateSetting),
        ("testResetSetting", testResetSetting),
        ("testGetSynonyms", testGetSynonyms),
        ("testUpdateSynonyms", testUpdateSynonyms),
        ("testResetSynonyms", testResetSynonyms),
    ]

}
