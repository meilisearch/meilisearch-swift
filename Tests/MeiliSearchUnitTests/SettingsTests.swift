@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
// swiftlint:disable force_try
class SettingsTests: XCTestCase {

  private var client: MeiliSearch!
  private var index: Indexes!
  private var uid: String = "movies_test"
  private let session = MockURLSession()

  private let json = """
    {
      "rankingRules": [
        "words",
        "typo",
        "proximity",
        "attribute",
        "sort",
        "exactness",
        "release_date:desc"
      ],
      "searchableAttributes": ["title", "description", "uid"],
      "displayedAttributes": [
        "title",
        "description",
        "release_date",
        "rank",
        "poster"
      ],
      "filterableAttributes": [],
      "sortableAttributes": [],
      "stopWords": [],
      "synonyms": {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"]
      }
    }
    """


  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  // MARK: Settings

  func testgetSettings() {


    // Prepare the mock server
    let stubSetting: SettingResult = buildStubSettingResult(from: json)
    session.pushData(json)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get settings")
    self.index.getSettings() { result in
      switch result {
      case .success(let setting):
        XCTAssertEqual(stubSetting, setting)
      case .failure:
        XCTFail("Failed to get settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testupdateSettings() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString)
    let setting: Setting = buildStubSetting(from: json)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update settings")

    self.index.updateSettings(setting) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetSettings() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let data: Data = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: data)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset settings")

    self.index.resetSettings() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Synonyms

  func testGetSynonyms() {

    let jsonString = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubSynonyms: [String: [String]] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get synonyms")

    self.index.getSynonyms() { result in
      switch result {
      case .success(let synonyms):
        XCTAssertEqual(stubSynonyms, synonyms)
      case .failure:
        XCTFail("Failed to get synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateSynonyms() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)
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

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update synonyms")
    self.index.updateSynonyms(synonyms) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetSynonyms() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset synonyms")

    self.index.resetSynonyms() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Stop words

  func testGetStopWords() {

    let jsonString = """
      ["of", "the", "to"]
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubStopWords: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get stop-words")

    self.index.getStopWords() { result in
      switch result {
      case .success(let stopWords):
        XCTAssertEqual(stubStopWords, stopWords)
      case .failure:
        XCTFail("Failed to get stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateStopWords() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """

    let stopWords: [String] = try! JSONSerialization.jsonObject(
      with: json.data(using: .utf8)!, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update stop-words")
    self.index.updateStopWords(stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetStopWords() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset stop-words")

    self.index.resetStopWords() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Ranking rules

  func testGetRankingRules() {

    let jsonString = """
      [
        "words",
        "typo",
        "proximity",
        "attribute",
        "sort",
        "exactness",
        "release_date:desc"
      ]
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubRakingRules: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get ranking rules")

    self.index.getRankingRules() { result in
      switch result {
      case .success(let rankingRules):
        XCTAssertEqual(stubRakingRules, rankingRules)
      case .failure:
        XCTFail("Failed to get ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateRankingRules() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """
    let stopWords: [String] = try! JSONSerialization.jsonObject(
      with: json.data(using: .utf8)!, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update ranking rules")

    self.index.updateRankingRules(stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetRankingRules() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset ranking rules")

    self.index.resetRankingRules() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Distinct Attribute

  func testGetDistinctAttribute() {

    let stubDistinctAttribute: String = """
      "movie_id"
      """

    // Prepare the mock server
    session.pushData(stubDistinctAttribute)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get distinct attribute")

    self.index.getDistinctAttribute() { result in
      switch result {
      case .success(let distinctAttribute):
        XCTAssertEqual("movie_id", distinctAttribute!)
      case .failure:
        XCTFail("Failed to get distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateDistinctAttribute() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)
    let distinctAttribute = "movie_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update distinct attribute")

    self.index.updateDistinctAttribute(distinctAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetDistinctAttribute() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset distinct attribute")

    self.index.resetDistinctAttribute() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Searchable Attribute

  func testGetSearchableAttributes() {

    let jsonString = """
      ["title", "description", "uid"]
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubSearchableAttribute: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get searchable attribute")

    self.index.getSearchableAttributes() { result in
      switch result {
      case .success(let searchableAttribute):
        XCTAssertEqual(stubSearchableAttribute, searchableAttribute)
      case .failure:
        XCTFail("Failed to get searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateSearchableAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    let json = """
      ["title", "description", "uid"]
      """
    let jsonData = json.data(using: .utf8)!
    let searchableAttribute: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update searchable attribute")
    self.index.updateSearchableAttributes(searchableAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetSearchableAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset searchable attribute")
    self.index.resetSearchableAttributes() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Displayed Attributes

  func testGetDisplayedAttributes() {

    let jsonString = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    // Prepare the mock server
    let jsonData = jsonString.data(using: .utf8)!
    let stubDisplayedAttributes: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getDisplayedAttributes() { result in
      switch result {
      case .success(let displayedAttributes):
        XCTAssertEqual(stubDisplayedAttributes, displayedAttributes)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateDisplayedAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    let json = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    let jsonData = json.data(using: .utf8)!
    let displayedAttributes: [String] = try! JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateDisplayedAttributes(displayedAttributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetDisplayedAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset displayed attribute")

    self.index.resetDisplayedAttributes() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to reset displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() {

    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getFilterableAttributes() { result in
      switch result {
      case .success(let filterableAttributes):
        XCTAssertFalse(filterableAttributes.isEmpty)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateFilterableAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateFilterableAttributes(attributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetFilterableAttributes() {

    let jsonString = """
      {"updateId":1}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.resetFilterableAttributes() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Filterable Attributes

  func testGetSortableAttributes() {

    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getSortableAttributes() { result in
      switch result {
      case .success(let sortableAttributes):
        XCTAssertFalse(sortableAttributes.isEmpty)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateSortableAttributes() {

    let jsonString = """
      {"updateId":0}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateSortableAttributes(attributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testResetSortableAttributes() {

    let jsonString = """
      {"updateId":1}
      """

    // Prepare the mock server
    let decoder: JSONDecoder = JSONDecoder()
    let stubUpdate: Update = try! decoder.decode(
      Update.self,
      from: jsonString.data(using: .utf8)!)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.resetSortableAttributes() { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  private func buildStubSetting(from json: String) -> Setting {
    let data = json.data(using: .utf8)!
    let decoder: JSONDecoder = JSONDecoder()
    return try! decoder.decode(Setting.self, from: data)
  }

  private func buildStubSettingResult(from json: String) -> SettingResult {
    let data = json.data(using: .utf8)!
    let decoder: JSONDecoder = JSONDecoder()
    return try! decoder.decode(SettingResult.self, from: data)
  }

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_cast
// swiftlint:enable force_try
