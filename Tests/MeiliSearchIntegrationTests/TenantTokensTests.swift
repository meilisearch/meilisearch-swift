@testable import MeiliSearch

import XCTest
import Foundation

class TenantTokensTests: XCTestCase {
  private var client: MeiliSearch!
  private var admClient: MeiliSearch!
  private var session: URLSessionProtocol!
  private let uid: String = "movies_test"
  private var key: String = ""

  override func setUpWithError() throws {
    super.setUp()

    let expectation = XCTestExpectation(description: "Create index with master key")

    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    createGenericIndex(client: client, uid: self.uid) { result in
      switch result {
      case .success:
        self.client.index(self.uid).updateFilterableAttributes(["id", "genres"]) { result in
          switch result {
          case .success(let task):
            self.client.waitForTask(task: task, options: WaitOptions(timeOut: 10.0)) { _ in
              expectation.fulfill()
            }
          case .failure:
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        expectation.fulfill()
      }
    }

    let keyExpectation = XCTestExpectation(description: "create key")

    self.client.createKey(KeyParams(description: "tenant token test swift", actions: ["*"], indexes: [uid], expiresAt: nil)) { result in
      switch result {
      case .success(let key):
        self.key = key.key
      case .failure:
        XCTFail("Failed to create key")
      }

      keyExpectation.fulfill()
    }

    self.wait(for: [expectation, keyExpectation], timeout: TESTS_TIME_OUT)
  }

  func testInvokesTokenGenerationWithoutValidApiKey() {
    let assertionHandler = { (result: Result<String, Error>) in
      switch result {
      case .success:
        XCTFail("Since there is no valid apiKey to sign the token, the creation should fail")
      case .failure(let error):
        XCTAssertNotNil(error)
      }
    }

    do {
      self.admClient = try MeiliSearch(host: "http://localhost:7700", apiKey: nil, session: self.session)

      self.admClient.generateTenantToken(SearchRulesGroup(SearchRules("*")), apiKey: nil, assertionHandler)
      self.admClient.generateTenantToken(SearchRulesGroup(SearchRules("*")), apiKey: "", assertionHandler)
    } catch let error {
      XCTFail("Failed: \(error.localizedDescription)")
    }
  }

  func testSearchesWithCustomTenantToken() throws {
    let expectation = XCTestExpectation(description: "Calls search methods with a client created with a custom jwt")

    let assertions: [SearchRulesGroup] = [
      SearchRulesGroup(SearchRules("*")),
      SearchRulesGroup(SearchRules("*", filter: "genres = Drama")),
      SearchRulesGroup(SearchRules(self.uid)),
      SearchRulesGroup(SearchRules(self.uid, filter: "genres = Drama")),
      SearchRulesGroup(SearchRules(self.uid, filter: "genres = Drama AND id = 1")),
      SearchRulesGroup([
        SearchRules(self.uid, filter: "genres = Drama AND id = 1"),
        SearchRules("other_index", filter: "type = anything")
      ])
    ]

    // closure that will handle the assertions for two different comparisons
    let assertionHandler = { (result: Result<String, Error>) in
      do {
        switch result {
        case .success(let jwt):
          XCTAssertNotNil(jwt)

          let searchClient = try MeiliSearch(host: "http://localhost:7700", apiKey: jwt, session: self.session)
          searchClient.index(self.uid).search(SearchParameters(query: "mad")) { (result: Result<SearchResult<Movie>, Swift.Error>) in
            switch result {
            case .success(let data):
              XCTAssertNotNil(data)
              expectation.fulfill()
            case .failure:
              XCTFail()
              expectation.fulfill()
            }
          }
        case .failure:
          XCTFail("The generateTenantToken cannot fail.")
          expectation.fulfill()
        }
      } catch {
        XCTFail("Failed to acquire a Meilisearch client")
      }
    }

    self.admClient = try MeiliSearch(host: "http://localhost:7700", apiKey: self.key, session: self.session)

    for group in assertions {
      self.admClient.generateTenantToken(group, assertionHandler)
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }
}
