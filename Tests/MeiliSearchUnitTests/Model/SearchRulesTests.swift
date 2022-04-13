@testable import MeiliSearch
import XCTest

class SearchRulesTests: XCTestCase {
  let encoder = JSONEncoder()
  let decoder = JSONDecoder()

  override func setUp() {
    // this is required to prevent flaky errors
    // during the comparison between the encoded value and the expected.
    self.encoder.outputFormatting = .sortedKeys
  }

  func testMatchesEncodedRules() {
    let expectations = [
      // without filters
      (SearchRules("*"), "[\"*\"]"),
      (SearchRules("books"), "[\"books\"]"),

      // complex filters
      (SearchRules("*", filter: "id = 1"), "{\"*\":{\"filter\":\"id = 1\"}}"),
      (SearchRules("books", filter: "id = 1 AND name = John"), "{\"books\":{\"filter\":\"id = 1 AND name = John\"}}"),

      // invalid filters
      (SearchRules("*", filter: ""), "[\"*\"]"),
      (SearchRules("*", filter: nil), "[\"*\"]")
    ]

    for (rule, json) in expectations {
      do {
        let encoded = try self.encoder.encode(rule)

        XCTAssert(
          json.data(using: .utf8) == encoded,
          """
          [encoding] the strings: \(json) aren't equal to \(String(data: encoded, encoding: .utf8) ?? "(empty)")
          check the values for inconsistencies, like spaces and typos.
          """
        )
      } catch {
        XCTFail("Failed to encode rule variable to JSON")
      }
    }
  }

  func testMatchesDecodedRules() {
    let expectations = [
      // without filters
      (SearchRules("*"), "[\"*\"]"),
      (SearchRules("books"), "[\"books\"]"),

      // complex filters
      (SearchRules("*", filter: "id = 1"), "{\"*\":{\"filter\":\"id = 1\"}}"),
      (SearchRules("books", filter: "id = 1 AND name = John"), "{\"books\":{\"filter\":\"id = 1 AND name = John\"}}"),

      // invalid filters
      (SearchRules("*", filter: nil), "[\"*\"]")
    ]

    for (rule, json) in expectations {
      do {
        if let data = json.data(using: .utf8) {
          let decoded = try decoder.decode(SearchRules.self, from: data)

          XCTAssertEqual(rule, decoded)
        } else {
          XCTFail("It was not possible to parse json var to data")
        }
      } catch {
        XCTFail("Failed to decode data to SearchRules")
      }
    }
  }

  func testMatchesEncodedGroups() {
    let expectations = [
      (SearchRulesGroup([SearchRules("books", filter: "id = 1"), SearchRules("movies", filter: "other_id = 1")]), "{\"books\":{\"filter\":\"id = 1\"},\"movies\":{\"filter\":\"other_id = 1\"}}"),
      (SearchRulesGroup([SearchRules("movies"), SearchRules("books")]), "{\"books\":{},\"movies\":{}}"),
      (SearchRulesGroup([SearchRules("books"), SearchRules("books")]), "{\"books\":{}}"),
      (SearchRulesGroup([SearchRules("books", filter: "id = 1"), SearchRules("books")]), "{\"books\":{}}"),
      (SearchRulesGroup([SearchRules("books"), SearchRules("books", filter: "id = 1")]), "{\"books\":{\"filter\":\"id = 1\"}}")
    ]

    for (rule, json) in expectations {
      do {
        let encoded = try self.encoder.encode(rule)

        XCTAssert(
          json.data(using: .utf8) == encoded,
          """
          [encoding] the strings: \(json) aren't equal to \(String(data: encoded, encoding: .utf8) ?? "(empty)")
          check the values for inconsistencies, like spaces and typos.
          """
        )
      } catch {
        XCTFail("Failed to encode rule variable to JSON")
      }
    }
  }

  func testDecodingFromUnexpectedPayloadFormats() {
    let expectations = [
      (SearchRulesGroup([SearchRules("books"), SearchRules("movies")]), "[\"books\",\"movies\"]"),
      (SearchRulesGroup(SearchRules("books")), "[\"books\"]")
    ]

    for (rule, json) in expectations {
      do {
        if let data = json.data(using: .utf8) {
          let decoded = try decoder.decode(SearchRulesGroup.self, from: data)

          XCTAssertEqual(rule, decoded)
        } else {
          XCTFail("It was not possible to parse json var to data")
        }
      } catch {
        XCTFail("Failed to decode data to SearchRules")
      }
    }
  }

  func testGroupDecodingWithInvalidPayloadFormats() {
    let json = "\"books\""

    do {
      if let data = json.data(using: .utf8) {
        _ = try decoder.decode(SearchRulesGroup.self, from: data)

        XCTFail("Should not be possible to parse this kind of JSON format")
      } else {
        XCTFail("Should not be possible to parse this kind of JSON format")
      }
    } catch let error {
      XCTAssertNotNil(error)
    }
  }

  func testRuleDecodingWithInvalidPayloadFormats() {
    let expectations = [
      "\"books\"",
      "[]"
    ]

    for json in expectations {
      do {
        if let data = json.data(using: .utf8) {
          _ = try decoder.decode(SearchRules.self, from: data)

          XCTFail("Should not be possible to parse this kind of JSON format")
        } else {
          XCTFail("Should not be possible to parse this kind of JSON format")
        }
      } catch let error {
        XCTAssertNotNil(error)
      }
    }
  }
}
