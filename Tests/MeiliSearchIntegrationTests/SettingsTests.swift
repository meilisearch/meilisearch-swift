@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_try
class SettingsTests: XCTestCase {

  private var client: MeiliSearch!
  private var index: Indexes!
  private let uid: String = "books_test"

  private let defaultRankingRules: [String] = [
    "words",
    "typo",
    "proximity",
    "attribute",
    "sort",
    "exactness"
  ]
  private let defaultDistinctAttribute: String? = nil
  private let defaultDisplayedAttributes: [String] = ["*"]
  private let defaultSearchableAttributes: [String] = ["*"]
  private let defaultFilterableAttributes: [String] = []
  private let defaultSortableAttributes: [String] = []
  private let defaultStopWords: [String] = []
  private let defaultSynonyms: [String: [String]] = [:]
  private var defaultGlobalSettings: Setting?
  private var defaultGlobalReturnedSettings: SettingResult?

  // MARK: Setup

  override func setUp() {
    super.setUp()

    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey")
    index = self.client.index(self.uid)

    let expectation = XCTestExpectation(description: "Create index if it does not exist")

    self.index.delete() { _ in
      self.client.getOrCreateIndex(self.uid) { result in
        switch result {
        case .success:
          expectation.fulfill()
        case .failure(let error):
          print(error)

        }
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)

    self.defaultGlobalSettings = Setting(
      rankingRules: self.defaultRankingRules,
      searchableAttributes: self.defaultSearchableAttributes,
      displayedAttributes: self.defaultDisplayedAttributes,
      stopWords: self.defaultStopWords,
      synonyms: self.defaultSynonyms,
      distinctAttribute: self.defaultDistinctAttribute,
      filterableAttributes: self.defaultFilterableAttributes,
      sortableAttributes: self.defaultFilterableAttributes
    )

    self.defaultGlobalReturnedSettings = SettingResult(
      rankingRules: self.defaultRankingRules,
      searchableAttributes: self.defaultSearchableAttributes,
      displayedAttributes: self.defaultDisplayedAttributes,
      stopWords: self.defaultStopWords,
      synonyms: self.defaultSynonyms,
      distinctAttribute: self.defaultDistinctAttribute,
      filterableAttributes: self.defaultFilterableAttributes,
      sortableAttributes: self.defaultSortableAttributes
    )

  }

  // MARK: Filterable Attributes

  func testGetFilterableAttributes() {

    let expectation = XCTestExpectation(description: "Get current filterable attributes")

    self.index.getFilterableAttributes() { result in
      switch result {
      case .success(let attributes):
        XCTAssertEqual(self.defaultFilterableAttributes, attributes)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateFilterableAttributes() {

    let expectation = XCTestExpectation(description: "Update settings for filterable attributes")
    let newFilterableAttributes: [String] = ["title"]

    self.index.updateFilterableAttributes(newFilterableAttributes) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getFilterableAttributes() { result in
            switch result {
            case .success(let attributes):
              XCTAssertEqual(newFilterableAttributes, attributes)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testResetFilterableAttributes() {

    let expectation = XCTestExpectation(description: "Reset settings for filterable attributes")

    self.index.resetFilterableAttributes() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getFilterableAttributes() { result in
            switch result {
            case .success(let attributes):
              XCTAssertEqual(self.defaultFilterableAttributes, attributes)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Displayed attributes

  func testGetDisplayedAttributes() {
    let expectation = XCTestExpectation(description: "Get current displayed attributes")

    self.index.getDisplayedAttributes() { result in
      switch result {
      case .success(let attributes):
        XCTAssertEqual(self.defaultDisplayedAttributes, attributes)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateDisplayedAttributes() {

    let expectation = XCTestExpectation(description: "Update settings for displayed attributes")
    let newDisplayedAttributes: [String] = ["title"]

    self.index.updateDisplayedAttributes(newDisplayedAttributes) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getDisplayedAttributes() { result in
            switch result {
            case .success(let attributes):
              XCTAssertEqual(newDisplayedAttributes, attributes)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testResetDisplayedAttributes() {

    let expectation = XCTestExpectation(description: "Reset settings for displayed attributes")

    self.index.resetDisplayedAttributes() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getDisplayedAttributes() { result in
            switch result {
            case .success(let attribute):
              XCTAssertEqual(self.defaultDisplayedAttributes, attribute)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Distinct attributes

  func testGetDistinctAttribute() {

    let expectation = XCTestExpectation(description: "Get current distinct attribute")

    self.index.getDistinctAttribute() { result in
      switch result {
      case .success(let attribute):
        XCTAssertEqual(self.defaultDistinctAttribute, attribute)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateDistinctAttribute() {

    let expectation = XCTestExpectation(description: "Update settings for distinct attribute")
    let newDistinctAttribute: String = "title"

    self.index.updateDistinctAttribute(newDistinctAttribute) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getDistinctAttribute() { result in
            switch result {
            case .success(let attribute):
              XCTAssertEqual(newDistinctAttribute, attribute)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testResetDistinctAttributes() {

    let expectation = XCTestExpectation(description: "Reset settings for distinct attributes")

    self.index.resetDistinctAttribute() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getDistinctAttribute() { result in
            switch result {
            case .success(let attribute):
              XCTAssertEqual(self.defaultDistinctAttribute, attribute)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Ranking rules

  func testGetRankingRules() {

    let expectation = XCTestExpectation(description: "Get current ranking rules")

    self.index.getRankingRules() { result in
      switch result {
      case .success(let rankingRules):
        XCTAssertEqual(self.defaultRankingRules, rankingRules)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateRankingRules() {

    let expectation = XCTestExpectation(description: "Update settings for ranking rules")

    let newRankingRules: [String] = [
      "words",
      "typo",
      "proximity"
    ]

    self.index.updateRankingRules(newRankingRules) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getRankingRules() { result in
            switch result {
            case .success(let rankingRules):
              XCTAssertEqual(newRankingRules, rankingRules)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testResetRankingRules() {

    let expectation = XCTestExpectation(description: "Reset settings for ranking rules")

    self.index.resetRankingRules() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getRankingRules() { result in
            switch result {
            case .success(let rankingRules):
              XCTAssertEqual(self.defaultRankingRules, rankingRules)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Searchable attributes

  func testGetSearchableAttributes() {

    let expectation = XCTestExpectation(description: "Get current searchable attributes")

    self.index.getSearchableAttributes() { result in
      switch result {
      case .success(let searchableAttributes):
        XCTAssertEqual(self.defaultSearchableAttributes, searchableAttributes)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateSearchableAttributes() {

    let expectation = XCTestExpectation(description: "Update settings for searchable attributes")

    let newSearchableAttributes: [String] = [
      "id",
      "title"
    ]

    self.index.updateSearchableAttributes(newSearchableAttributes) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSearchableAttributes() { result in
            switch result {
            case .success(let searchableAttributes):
              XCTAssertEqual(newSearchableAttributes, searchableAttributes)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }

    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testResetSearchableAttributes() {

    let expectation = XCTestExpectation(description: "Reset settings for searchable attributes")

    self.index.resetSearchableAttributes() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSearchableAttributes() { result in
            switch result {
            case .success(let searchableAttributes):
              XCTAssertEqual(self.defaultSearchableAttributes, searchableAttributes)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // // MARK: Stop words

  func testGetStopWords() {

    let expectation = XCTestExpectation(description: "Get current stop words")

    self.index.getStopWords() { result in
      switch result {

      case .success(let stopWords):
        XCTAssertEqual(self.defaultStopWords, stopWords)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateStopWords() {

    let expectation = XCTestExpectation(description: "Update stop words")

    let newStopWords: [String] = ["the"]

    self.index.updateStopWords(newStopWords) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getStopWords() { result in
            switch result {
            case .success(let finalStopWords):
              XCTAssertEqual(newStopWords, finalStopWords)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }

    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testUpdateStopWordsWithEmptyArray() {

    let expectation = XCTestExpectation(description: "Update stop words")

    let nilStopWords: [String]? = [String]()

    self.index.updateStopWords(nilStopWords) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getStopWords() { result in

            switch result {
            case .success(let finalStopWords):
              XCTAssertEqual(finalStopWords, [])
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }

    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testUpdateStopWordsWithNullValue() {

    let expectation = XCTestExpectation(description: "Update stop words")

    let nilStopWords: [String]? = nil

    self.index.updateStopWords(nilStopWords) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getStopWords() { result in

            switch result {
            case .success(let finalStopWords):
              XCTAssertEqual(finalStopWords, [])
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }

    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testResetStopWords() {

    let expectation = XCTestExpectation(description: "Reset stop words")

    self.index.resetStopWords() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getStopWords() { result in
            switch result {
            case .success(let stopWords):
              XCTAssertEqual(self.defaultStopWords, stopWords)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Synonyms

  func testGetSynonyms() {

    let expectation = XCTestExpectation(description: "Get current synonyms")

    self.index.getSynonyms() { result in
      switch result {
      case .success(let synonyms):
        XCTAssertEqual(self.defaultSynonyms, synonyms)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateSynonyms() {

    let expectation = XCTestExpectation(description: "Update synonyms")

    let newSynonyms: [String: [String]] = [
      "wolverine": ["xmen", "logan"],
      "logan": ["wolverine", "xmen"],
      "wow": ["world of warcraft"],
      "rct": ["rollercoaster tycoon"]
    ]

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSynonyms() { result in
            switch result {
            case .success(let updatedSynonyms):
              let rhs = Array(updatedSynonyms.keys).sorted(by: <)
              XCTAssertEqual(Array(newSynonyms.keys).sorted(by: <), rhs)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testUpdateSynonymsEmptyString() {

    let expectation = XCTestExpectation(description: "Update synonyms")
    let newSynonyms = [String: [String]]()

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSynonyms() { result in
            switch result {
            case .success(let updatedSynonyms):
              XCTAssertEqual(updatedSynonyms, [:])
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testUpdateSynonymsNil() {

    let expectation = XCTestExpectation(description: "Update synonyms")

    let newSynonyms: [String: [String]]? = nil

    self.index.updateSynonyms(newSynonyms) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSynonyms() { result in
            switch result {
            case .success(let updatedSynonyms):
              XCTAssertEqual(updatedSynonyms, [:])
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testResetSynonyms() {

    let expectation = XCTestExpectation(description: "Reset synonyms")

    self.index.resetSynonyms() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSynonyms() { result in
            switch result {
            case .success(let synonyms):
              XCTAssertEqual(self.defaultSynonyms, synonyms)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  // MARK: Global Settings

  func testgetSettingss() {

    let expectation = XCTestExpectation(description: "Get current settings")

    self.index.getSettings() { result in
      switch result {
      case .success(let settings):
        XCTAssertEqual(self.defaultGlobalReturnedSettings, settings)
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testupdateSettingss() {
    let newSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      stopWords: ["the", "a"]
    )

    let overrideSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"]
    )

    let expectedSettingResult = SettingResult(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: ["the", "a"],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: [],
      sortableAttributes: ["title"]
    )

    let expectation = XCTestExpectation(description: "Update settings")
    self.index.updateSettings(newSettings) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSettings() { result in
            switch result {
            case .success(let settingResult):
              XCTAssertEqual(expectedSettingResult.rankingRules.sorted(), settingResult.rankingRules.sorted())
              XCTAssertEqual(expectedSettingResult.searchableAttributes.sorted(), settingResult.searchableAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.displayedAttributes.sorted(), settingResult.displayedAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.stopWords.sorted(), settingResult.stopWords.sorted())
              XCTAssertEqual([], settingResult.filterableAttributes)
              XCTAssertEqual(Array(expectedSettingResult.synonyms.keys).sorted(by: <), Array(settingResult.synonyms.keys).sorted(by: <))
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [expectation], timeout: 10.0)

    let overrideSettingsExpectation = XCTestExpectation(description: "Update settings")

    // Test if absents settings are sent to MeiliSearch with a nil value.
    self.index.updateSettings(overrideSettings) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSettings() { result in
            switch result {
            case .success(let settingResult):
              XCTAssertEqual(expectedSettingResult.rankingRules.sorted(), settingResult.rankingRules.sorted())
              XCTAssertEqual(expectedSettingResult.searchableAttributes.sorted(), settingResult.searchableAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.displayedAttributes.sorted(), settingResult.displayedAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.stopWords.sorted(), settingResult.stopWords.sorted())
              XCTAssertEqual(expectedSettingResult.filterableAttributes, [])
              XCTAssertEqual(Array(expectedSettingResult.synonyms.keys).sorted(by: <), Array(settingResult.synonyms.keys).sorted(by: <))
            case .failure(let error):
              print(error)
              XCTFail()
            }
            overrideSettingsExpectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }
    self.wait(for: [overrideSettingsExpectation], timeout: 10.0)
  }

  func testupdateSettingssWithSynonymsAndStopWordsNil() {

    let expectation = XCTestExpectation(description: "Update settings")

    let newSettings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: nil,
      synonyms: nil,
      distinctAttribute: nil,
      filterableAttributes: ["title"],
      sortableAttributes: ["title"])

    let expectedSettingResult = SettingResult(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["id", "title"],
      displayedAttributes: ["*"],
      stopWords: [],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: ["title"],
      sortableAttributes: ["title"])

    self.index.updateSettings(newSettings) { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSettings() { result in
            switch result {
            case .success(let finalSetting):
              XCTAssertEqual(expectedSettingResult.rankingRules.sorted(), finalSetting.rankingRules.sorted())
              XCTAssertEqual(expectedSettingResult.searchableAttributes.sorted(), finalSetting.searchableAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.displayedAttributes.sorted(), finalSetting.displayedAttributes.sorted())
              XCTAssertEqual(expectedSettingResult.stopWords.sorted(), finalSetting.stopWords.sorted())
              XCTAssertEqual(expectedSettingResult.filterableAttributes, finalSetting.filterableAttributes)
              XCTAssertEqual(Array(expectedSettingResult.synonyms.keys).sorted(by: <), Array(finalSetting.synonyms.keys).sorted(by: <))
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }

    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testresetSettingss() {

    let expectation = XCTestExpectation(description: "Reset settings")

    self.index.resetSettings() { result in
      switch result {
      case .success(let update):
        waitForPendingUpdate(self.client, self.uid, update) {
          self.index.getSettings() { result in
            switch result {
            case .success(let settings):
              XCTAssertEqual(self.defaultGlobalReturnedSettings, settings)
            case .failure(let error):
              print(error)
              XCTFail()
            }
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

}
// swiftlint:enable force_try
