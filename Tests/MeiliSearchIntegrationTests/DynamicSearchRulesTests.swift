@testable import MeiliSearch
import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif
import XCTest

class DynamicSearchRulesTests: XCTestCase {
  private let ruleUid = "swift-sdk-issue-528-lifecycle"
  private var client: MeiliSearch!
  private var session: URLSession!

  override func setUpWithError() throws {
    try super.setUpWithError()
    session = URLSession(configuration: .ephemeral)
    client = try MeiliSearch(
      host: currentHost(),
      apiKey: "masterKey",
      session: session
    )

    try enableDynamicSearchRules()
    try deleteLifecycleRule()
  }

  override func tearDownWithError() throws {
    try deleteLifecycleRule()
    client = nil
    session.invalidateAndCancel()
    session = nil
    try super.tearDownWithError()
  }

  func testDynamicSearchRulesLifecycle() async throws {
    let initialParams = DynamicSearchRuleParams(
      description: "Issue 528 lifecycle rule",
      precedence: 10,
      active: true,
      conditions: DynamicSearchRuleConditions(
        query: DynamicSearchRuleQueryCondition(words: "summer sale")
      ),
      actions: [
        DynamicSearchRuleAction(
          selector: DynamicSearchRuleSelector(indexUid: "products", id: "123"),
          action: DynamicSearchRuleActionPayload(position: 1)
        )
      ]
    )

    let createTask = try await client.updateOrCreateDynamicSearchRule(
      uid: ruleUid,
      ruleParams: initialParams
    )
    XCTAssertEqual(createTask.type, .dynamicSearchRuleUpdate)
    let created = try await client.waitForTask(task: createTask)
    XCTAssertEqual(created.status, .succeeded)

    let fetched = try await client.getDynamicSearchRule(uid: ruleUid)
    XCTAssertEqual(fetched.uid, ruleUid)
    XCTAssertEqual(fetched.description, initialParams.description)
    XCTAssertEqual(fetched.precedence, initialParams.precedence)
    XCTAssertEqual(fetched.conditions, initialParams.conditions)
    XCTAssertEqual(fetched.actions, initialParams.actions)

    let listed = try await client.listDynamicSearchRules(
      params: DynamicSearchRulesQuery(
        offset: 0,
        limit: 1,
        filter: DynamicSearchRulesFilter(query: "lifecycle", active: true)
      )
    )
    XCTAssertEqual(listed.offset, 0)
    XCTAssertEqual(listed.limit, 1)
    XCTAssertEqual(listed.total, 1)
    XCTAssertEqual(listed.results.first?.uid, ruleUid)

    let updateTask = try await client.updateOrCreateDynamicSearchRule(
      uid: ruleUid,
      ruleParams: DynamicSearchRuleParams(
        description: "Updated issue 528 lifecycle rule",
        active: false
      )
    )
    XCTAssertEqual(updateTask.type, .dynamicSearchRuleUpdate)
    let updated = try await client.waitForTask(task: updateTask)
    XCTAssertEqual(updated.status, .succeeded)

    let updatedRule = try await client.getDynamicSearchRule(uid: ruleUid)
    XCTAssertEqual(updatedRule.description, "Updated issue 528 lifecycle rule")
    XCTAssertFalse(updatedRule.active)
    XCTAssertEqual(updatedRule.conditions, initialParams.conditions)
    XCTAssertEqual(updatedRule.actions, initialParams.actions)

    let deleteTask = try await client.deleteDynamicSearchRule(uid: ruleUid)
    XCTAssertEqual(deleteTask.type, .dynamicSearchRuleUpdate)
    let deleted = try await client.waitForTask(task: deleteTask)
    XCTAssertEqual(deleted.status, .succeeded)

    do {
      _ = try await client.getDynamicSearchRule(uid: ruleUid)
      XCTFail("Expected the deleted rule to be unavailable")
    } catch let error as MeiliSearch.Error {
      switch error {
      case .meiliSearchApiError(_, let response, _, _):
        XCTAssertEqual(response?.code, "dynamic_search_rule_not_found")
      default:
        XCTFail("Unexpected Meilisearch error: \(error)")
      }
    }
  }

  private func enableDynamicSearchRules() throws {
    let url = try XCTUnwrap(URL(string: "\(currentHost())/experimental-features"))
    var request = URLRequest(url: url)
    request.httpMethod = "PATCH"
    request.setValue("Bearer masterKey", forHTTPHeaderField: "Authorization")
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = Data("{\"dynamicSearchRules\":true}".utf8)

    let expectation = XCTestExpectation(description: "Enable dynamic search rules")
    var requestError: Swift.Error?
    session.dataTask(with: request) { data, response, error in
      defer { expectation.fulfill() }
      if let error = error {
        requestError = error
        return
      }
      guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
        requestError = MeiliSearch.Error.invalidJSON
        return
      }
      guard
        let data = data,
        let features = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
        features["dynamicSearchRules"] as? Bool == true
      else {
        requestError = MeiliSearch.Error.invalidJSON
        return
      }
    }.resume()

    wait(for: [expectation], timeout: TESTS_TIME_OUT)
    if let requestError = requestError {
      throw requestError
    }
  }

  private func deleteLifecycleRule() throws {
    let expectation = XCTestExpectation(description: "Clean up dynamic search rule")
    var cleanupError: Swift.Error?

    client.deleteDynamicSearchRule(uid: ruleUid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          if case .failure(let error) = result {
            cleanupError = error
          }
          expectation.fulfill()
        }
      case .failure(let error):
        cleanupError = error
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: TESTS_TIME_OUT)
    if let cleanupError = cleanupError {
      throw cleanupError
    }
  }
}
