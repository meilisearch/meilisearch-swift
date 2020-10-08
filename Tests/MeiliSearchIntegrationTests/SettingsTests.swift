@testable import MeiliSearch
import XCTest
import Foundation

class SettingsTests: XCTestCase {

    private var client: MeiliSearch!
    private let uid: String = "books_test"
    private let defaultGlobalSettings: Setting = Setting(
        rankingRules: ["typo", "words", "proximity", "attribute", "wordsPosition", "exactness"],
        searchableAttributes: ["*"],
        displayedAttributes: ["*"],
        stopWords: [],
        synonyms: [:],
        distinctAttribute: nil,
        attributesForFaceting: [])

    // MARK: Setup

    override func setUp() {
        super.setUp()

        if client == nil {
            client = try! MeiliSearch(
              Config.default(apiKey: "masterKey"))
        }

        pool(client)

        let expectation = XCTestExpectation(description: "Create index if it does not exist")

        self.client.deleteIndex(UID: uid) { _ in
            Thread.sleep(forTimeInterval: TimeInterval(0.1))
            self.client.getOrCreateIndex(UID: self.uid) { result in
                switch result {
                case .success:
                    expectation.fulfill()
                case .failure(let error):
                    print(error)
                    XCTFail()
                }
            }
        }

        self.wait(for: [expectation], timeout: 10.0)
    }

    // MARK: Attributes for faceting

    func testGetAttributesForFaceting() {

        let expectation = XCTestExpectation(description: "Get current attributes for faceting")

        let defaultAttributesForFaceting: [String] = []

        self.client.getAttributesForFaceting(UID: self.uid) { result in
            switch result {
            case .success(let attributes):

                XCTAssertEqual(defaultAttributesForFaceting, attributes)

                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateAttributesForFaceting() {

        let expectation = XCTestExpectation(description: "Update settings for attributes for faceting")

        let newAttributesForFaceting: [String] = ["title"]

        self.client.updateAttributesForFaceting(UID: self.uid, newAttributesForFaceting) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getAttributesForFaceting(UID: self.uid) { result in

                    switch result {
                    case .success(let attributes):

                        XCTAssertEqual(newAttributesForFaceting, attributes)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 2.0)
    }

    func testResetAttributesForFaceting() {

        let expectation = XCTestExpectation(description: "Reset settings for attributes for faceting")

        self.client.resetAttributesForFaceting(UID: self.uid) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getAttributesForFaceting(UID: self.uid) { result in

                    switch result {
                    case .success(let attributes):

                        XCTAssertTrue(attributes.isEmpty)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Displayed attributes

    func testGetDisplayedAttributes() {

        let expectation = XCTestExpectation(description: "Get current displayed attributes")

        let defaultDisplayedAttributes = ["*"]

                self.client.getDisplayedAttributes(UID: self.uid) { result in

                    switch result {
                    case .success(let attributes):

                        XCTAssertEqual(defaultDisplayedAttributes, attributes)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateDisplayedAttributes() {

        let expectation = XCTestExpectation(description: "Update settings for displayed attributes")

        let newDisplayedAttributes: [String] = ["title"]

        self.client.updateDisplayedAttributes(UID: self.uid, newDisplayedAttributes) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getDisplayedAttributes(UID: self.uid) { result in

                    switch result {
                    case .success(let attributes):

                        XCTAssertEqual(newDisplayedAttributes, attributes)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetDisplayedAttributes(UID: self.uid) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getDisplayedAttributes(UID: self.uid) { result in

                    switch result {
                    case .success(let attribute):

                        XCTAssertEqual(["*"], attribute)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Distinct attributes

    func testGetDistinctAttribute() {

        let expectation = XCTestExpectation(description: "Get current distinct attribute")

        self.client.getDistinctAttribute(UID: self.uid) { result in

            switch result {
            case .success(let attribute):

                XCTAssertNil(attribute)
                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }

        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateDistinctAttribute() {

        let expectation = XCTestExpectation(description: "Update settings for distinct attribute")

        let newDistinctAttribute: String = "title"

        self.client.updateDistinctAttribute(UID: self.uid, newDistinctAttribute) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getDistinctAttribute(UID: self.uid) { result in

                    switch result {
                    case .success(let attribute):

                        XCTAssertEqual(newDistinctAttribute, attribute)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetDistinctAttribute(UID: self.uid) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getDistinctAttribute(UID: self.uid) { result in

                    switch result {
                    case .success(let attribute):

                        XCTAssertNil(attribute)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Ranking rules

    func testGetRankingRules() {

        let expectation = XCTestExpectation(description: "Get current ranking rules")

        let defaultRankingRules: [String] = [
            "typo",
            "words",
            "proximity",
            "attribute",
            "wordsPosition",
            "exactness"
        ]

        self.client.getRankingRules(UID: self.uid) { result in
            switch result {
            case .success(let rankingRules):

                XCTAssertEqual(defaultRankingRules, rankingRules)

                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateRankingRules() {

        let expectation = XCTestExpectation(description: "Update settings for ranking rules")

        let initialRankingRules: [String] = [
            "typo",
            "words",
            "proximity"
        ]

        self.client.updateRankingRules(UID: self.uid, initialRankingRules) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getRankingRules(UID: self.uid) { result in

                    switch result {
                    case .success(let rankingRules):

                        XCTAssertEqual(initialRankingRules, rankingRules)
                        let newRankingRules: [String] = [
                            "words",
                            "typo",
                            "proximity"
                        ]

                        self.client.updateRankingRules(UID: self.uid, newRankingRules) { result in
                            switch result {
                            case .success:

                              Thread.sleep(forTimeInterval: 0.5)

                              self.client.getRankingRules(UID: self.uid) { result in

                                  switch result {
                                  case .success(let rankingRules):

                                      XCTAssertNotEqual(initialRankingRules, rankingRules)
                                      XCTAssertEqual(newRankingRules, rankingRules)

                                      expectation.fulfill()

                                  case .failure(let error):
                                      print(error)
                                      XCTFail()
                                  }

                              }

                            case .failure(let error):
                                print(error)
                                XCTFail()
                            }
                        }

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetRankingRules(UID: self.uid) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getRankingRules(UID: self.uid) { result in

                    switch result {
                    case .success(let rankingRules):

                        XCTAssertEqual(["typo", "words", "proximity", "attribute", "wordsPosition", "exactness"], rankingRules)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Searchable attributes

    func testGetSearchableAttributes() {

        let expectation = XCTestExpectation(description: "Get current searchable attributes")

        let defaultSearchableAttributes: [String] = ["*"]

        self.client.getSearchableAttributes(UID: self.uid) { result in
            switch result {
            case .success(let searchableAttributes):

                XCTAssertEqual(defaultSearchableAttributes, searchableAttributes)

                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateSearchableAttributes() {

        let expectation = XCTestExpectation(description: "Update settings for searchable attributes")

        let newRankingRules: [String] = [
            "id",
            "title"
        ]

        self.client.updateSearchableAttributes(UID: self.uid, newRankingRules) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getSearchableAttributes(UID: self.uid) { result in

                    switch result {
                    case .success(let rankingRules):

                        XCTAssertEqual(newRankingRules, rankingRules)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetSearchableAttributes(UID: self.uid) { result in

            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getSearchableAttributes(UID: self.uid) { result in

                    switch result {
                    case .success(let rankingRules):

                        XCTAssertEqual(["*"], rankingRules)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // // MARK: Stop words

    func testGetStopWords() {

        let expectation = XCTestExpectation(description: "Get current stop words")

        let defaultStopWords: [String] = []

        self.client.getStopWords(UID: self.uid) { result in
            switch result {

            case .success(let stopWords):
                XCTAssertEqual(defaultStopWords, stopWords)
                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateStopWords() {

        let expectation = XCTestExpectation(description: "Update stop words")

        let newStopWords: [String] = ["the"]

        self.client.updateStopWords(UID: self.uid, newStopWords) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getStopWords(UID: self.uid) { result in

                    switch result {
                    case .success(let finalStopWords):

                        XCTAssertEqual(newStopWords, finalStopWords)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetStopWords(UID: self.uid) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getStopWords(UID: self.uid) { result in

                    switch result {
                    case .success(let stopWords):
                        XCTAssertTrue(stopWords.isEmpty)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Synonyms

    func testGetSynonyms() {

        let expectation = XCTestExpectation(description: "Get current synonyms")

        let defaultSynonyms: [String: [String]] = [:]

        self.client.getSynonyms(UID: self.uid) { result in
            switch result {
            case .success(let synonyms):

                XCTAssertEqual(defaultSynonyms, synonyms)
                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateSynonyms() {

        let expectation = XCTestExpectation(description: "Update synonyms")

        let newSynonyms: [String: [String]] = [
            "wolverine": ["xmen", "logan"],
            "logan": ["wolverine", "xmen"],
            "wow": ["world of warcraft"],
            "rct": ["rollercoaster tycoon"]
        ]

        self.client.updateSynonyms(UID: self.uid, newSynonyms) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getSynonyms(UID: self.uid) { result in

                    switch result {
                    case .success(let updatedSynonyms):

                        let rhs = Array(updatedSynonyms.keys).sorted(by: <)
                        XCTAssertEqual(Array(newSynonyms.keys).sorted(by: <), rhs)

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
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

        self.client.resetSynonyms(UID: self.uid) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getSynonyms(UID: self.uid) { result in

                    switch result {
                    case .success(let synonyms):

                      XCTAssertTrue(synonyms.isEmpty)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    // MARK: Global Settings

    func testGetSettings() {

        let expectation = XCTestExpectation(description: "Get current settings")

        self.client.getSetting(UID: self.uid) { result in
            switch result {
            case .success(let settings):
                XCTAssertEqual(self.defaultGlobalSettings, settings)
                expectation.fulfill()

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

    func testUpdateSettings() {

        let expectation = XCTestExpectation(description: "Update settings")

        let newSettings: Setting = Setting(
            rankingRules: ["words", "typo", "proximity", "attribute", "wordsPosition", "exactness"],
            searchableAttributes: ["id", "title"],
            displayedAttributes: ["*"],
            stopWords: ["the", "a"],
            synonyms: [:],
            distinctAttribute: nil,
            attributesForFaceting: ["title"])

        self.client.updateSetting(UID: self.uid, newSettings) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: 0.5)

                self.client.getSetting(UID: self.uid) { result in

                    switch result {
                    case .success(let finalSetting):

                        XCTAssertEqual(newSettings.rankingRules.sorted(), finalSetting.rankingRules.sorted())
                        XCTAssertEqual(newSettings.searchableAttributes.sorted(), finalSetting.searchableAttributes.sorted())
                        XCTAssertEqual(newSettings.displayedAttributes.sorted(), finalSetting.displayedAttributes.sorted())
                        XCTAssertEqual(newSettings.stopWords.sorted(), finalSetting.stopWords.sorted())
                        XCTAssertEqual(newSettings.attributesForFaceting, finalSetting.attributesForFaceting)
                        XCTAssertEqual(Array(newSettings.synonyms.keys).sorted(by: <), Array(finalSetting.synonyms.keys).sorted(by: <))

                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }

        }

        self.wait(for: [expectation], timeout: 10.0)
    }

    func testResetSettings() {

        let expectation = XCTestExpectation(description: "Reset settings")

        self.client.resetSetting(UID: self.uid) { result in
            switch result {
            case .success:

                Thread.sleep(forTimeInterval: TimeInterval(0.5))

                self.client.getSetting(UID: self.uid) { result in

                    switch result {
                    case .success(let settings):

                        XCTAssertEqual(self.defaultGlobalSettings, settings)
                        expectation.fulfill()

                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

            case .failure(let error):
                print(error)
                XCTFail()
            }
        }

        self.wait(for: [expectation], timeout: 1.0)
    }

}
