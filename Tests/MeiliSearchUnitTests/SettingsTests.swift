@testable import MeiliSearch
import XCTest

// swiftlint:disable force_cast
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
      "separatorTokens": [],
      "nonSeparatorTokens": [],
      "dictionary": [],
      "pagination": {
        "maxTotalHits": 1000
      },
      "synonyms": {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"]
      },
      "typoTolerance": {
        "enabled": true,
        "minWordSizeForTypos": {
          "oneTypo": 5,
          "twoTypos": 9
        },
        "disableOnWords": [],
        "disableOnAttributes": []
      }
    }
    """

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  // MARK: Settings

  func testGetSettings() throws {
    // Prepare the mock server
    let stubSetting: SettingResult = try buildStubSettingResult(from: json)
    session.pushData(json)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get settings")
    self.index.getSettings { result in
      switch result {
      case .success(let setting):
        XCTAssertEqual(stubSetting, setting)
      case .failure:
        XCTFail("Failed to get settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSettings() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let jsonData = Data(jsonString.utf8)
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: jsonData)

    session.pushData(jsonString)
    let setting: Setting = try buildStubSetting(from: json)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update settings")

    self.index.updateSettings(setting) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSettings() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let data: Data = Data(jsonString.utf8)
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: data)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset settings")

    self.index.resetSettings { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset settings")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Synonyms

  func testGetSynonyms() throws {
    let jsonString = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubSynonyms: [String: [String]] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get synonyms")

    self.index.getSynonyms { result in
      switch result {
      case .success(let synonyms):
        XCTAssertEqual(stubSynonyms, synonyms)
      case .failure:
        XCTFail("Failed to get synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSynonyms() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let json = """
      {
        "wolverine": ["xmen", "logan"],
        "logan": ["wolverine", "xmen"],
        "wow": ["world of warcraft"]
      }
      """
    let jsonData = Data(json.utf8)
    let synonyms: [String: [String]] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String: [String]]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update synonyms")
    self.index.updateSynonyms(synonyms) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSynonyms() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset synonyms")

    self.index.resetSynonyms { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset synonyms")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Stop words

  func testGetStopWords() throws {
    let jsonString = """
      ["of", "the", "to"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubStopWords: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get stop-words")

    self.index.getStopWords { result in
      switch result {
      case .success(let stopWords):
        XCTAssertEqual(stubStopWords, stopWords)
      case .failure:
        XCTFail("Failed to get stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateStopWords() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """

    let stopWords: [String] = try JSONSerialization.jsonObject(
      with: Data(json.utf8), options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update stop-words")
    self.index.updateStopWords(stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(update, stubTask)
      case .failure:
        XCTFail("Failed to update stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetStopWords() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset stop-words")

    self.index.resetStopWords { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset stop-words")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Ranking rules

  func testGetRankingRules() throws {
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
    let jsonData = Data(jsonString.utf8)
    let stubRankingRules: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get ranking rules")

    self.index.getRankingRules { result in
      switch result {
      case .success(let rankingRules):
        XCTAssertEqual(stubRankingRules, rankingRules)
      case .failure:
        XCTFail("Failed to get ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateRankingRules() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let json = """
      ["of", "the", "to"]
      """
    let stopWords: [String] = try JSONSerialization.jsonObject(
      with: Data(json.utf8), options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update ranking rules")

    self.index.updateRankingRules(stopWords) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetRankingRules() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset ranking rules")

    self.index.resetRankingRules { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset ranking rules")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Distinct Attribute

  func testGetDistinctAttribute() throws {
    let stubDistinctAttribute: String = """
      "movie_id"
      """

    // Prepare the mock server
    session.pushData(stubDistinctAttribute)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get distinct attribute")

    self.index.getDistinctAttribute { result in
      switch result {
      case .success(let distinctAttribute):
        XCTAssertEqual("movie_id", distinctAttribute)
      case .failure:
        XCTFail("Failed to get distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDistinctAttribute() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)
    let distinctAttribute = "movie_id"

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update distinct attribute")

    self.index.updateDistinctAttribute(distinctAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetDistinctAttribute() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset distinct attribute")

    self.index.resetDistinctAttribute { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset distinct attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Searchable Attribute

  func testGetSearchableAttributes() throws {
    let jsonString = """
      ["title", "description", "uid"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubSearchableAttribute: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get searchable attribute")

    self.index.getSearchableAttributes { result in
      switch result {
      case .success(let searchableAttribute):
        XCTAssertEqual(stubSearchableAttribute, searchableAttribute)
      case .failure:
        XCTFail("Failed to get searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSearchableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    let json = """
      ["title", "description", "uid"]
      """
    let jsonData = Data(json.utf8)
    let searchableAttribute: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update searchable attribute")
    self.index.updateSearchableAttributes(searchableAttribute) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSearchableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset searchable attribute")
    self.index.resetSearchableAttributes { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset searchable attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Displayed Attributes

  func testGetDisplayedAttributes() throws {
    let jsonString = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    // Prepare the mock server
    let jsonData = Data(jsonString.utf8)
    let stubDisplayedAttributes: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getDisplayedAttributes { result in
      switch result {
      case .success(let displayedAttributes):
        XCTAssertEqual(stubDisplayedAttributes, displayedAttributes)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDisplayedAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    let json = """
      ["title", "description", "release_date", "rank", "poster"]
      """

    let jsonData = Data(json.utf8)
    let displayedAttributes: [String] = try JSONSerialization.jsonObject(
      with: jsonData, options: []) as! [String]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateDisplayedAttributes(displayedAttributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetDisplayedAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Reset displayed attribute")

    self.index.resetDisplayedAttributes { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to reset displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() throws {
    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getFilterableAttributes { result in
      switch result {
      case .success(let filterableAttributes):
        XCTAssertFalse(filterableAttributes.isEmpty)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateFilterableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateFilterableAttributes(attributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetFilterableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.resetFilterableAttributes { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Filterable Attributes

  func testGetSortableAttributes() throws {
    let jsonString = """
      ["genre", "director"]
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getSortableAttributes { result in
      switch result {
      case .success(let sortableAttributes):
        XCTAssertFalse(sortableAttributes.isEmpty)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateSortableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let attributes: [String] = ["genre", "director"]

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateSortableAttributes(attributes) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetSortableAttributes() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(
      TaskInfo.self,
      from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.resetSortableAttributes { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  // MARK: Typo Tolerance

  func testGetTypoTolerance() {
    let jsonString = """
      {"enabled":true,"minWordSizeForTypos":{"oneTypo":3,"twoTypos":7},"disableOnWords":["of", "the"],"disableOnAttributes":["genre"]}
      """

    // Prepare the mock server
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Get displayed attribute")

    self.index.getTypoTolerance { result in
      switch result {
      case .success(let typoTolerance):
        XCTAssertTrue(typoTolerance.enabled)
        XCTAssertEqual(typoTolerance.minWordSizeForTypos.oneTypo, 3)
        XCTAssertEqual(typoTolerance.minWordSizeForTypos.twoTypos, 7)
        XCTAssertFalse(typoTolerance.disableOnWords.isEmpty)
        XCTAssertFalse(typoTolerance.disableOnAttributes.isEmpty)
      case .failure:
        XCTFail("Failed to get displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateTypoTolerance() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: Data(jsonString.utf8))

    session.pushData(jsonString)
    let typoTolerance: TypoTolerance = .init(enabled: false)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.updateTypoTolerance(typoTolerance) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testResetTypoTolerance() throws {
    let jsonString = """
      {"taskUid":0,"indexUid":"movies_test","status":"enqueued","type":"settingsUpdate","enqueuedAt":"2022-07-27T19:03:50.494232841Z"}
      """

    // Prepare the mock server
    let decoder = Constants.customJSONDecoder
    let stubTask: TaskInfo = try decoder.decode(TaskInfo.self, from: Data(jsonString.utf8))
    session.pushData(jsonString)

    // Start the test with the mocked server
    let expectation = XCTestExpectation(description: "Update displayed attribute")

    self.index.resetTypoTolerance { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(stubTask, update)
      case .failure:
        XCTFail("Failed to update displayed attribute")
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  private func buildStubSetting(from json: String) throws -> Setting {
    let data = Data(json.utf8)
    let decoder = Constants.customJSONDecoder
    return try decoder.decode(Setting.self, from: data)
  }

  private func buildStubSettingResult(from json: String) throws -> SettingResult {
    let data = Data(json.utf8)
    let decoder = Constants.customJSONDecoder
    return try decoder.decode(SettingResult.self, from: data)
  }
}
// swiftlint:enable force_cast
