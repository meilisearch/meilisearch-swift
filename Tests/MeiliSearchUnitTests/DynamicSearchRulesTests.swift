@testable import MeiliSearch
import Foundation
import XCTest

class DynamicSearchRulesTests: XCTestCase {
  private var client: MeiliSearch!
  private let session = MockURLSession()

  override func setUpWithError() throws {
    try super.setUpWithError()
    client = try MeiliSearch(
      host: "http://localhost:7700",
      apiKey: "masterKey",
      session: session
    )
  }

  func testListDynamicSearchRulesUsesPostBodyAndDecodesResults() async throws {
    let json = """
      {
        "results": [
          {
            "uid": "black-friday",
            "description": "Black Friday rules",
            "precedence": 10,
            "active": true,
            "conditions": {
              "query": { "words": "black friday" },
              "time": {
                "start": "2026-11-27T00:00:00Z",
                "end": "2026-11-28T00:00:00Z"
              }
            },
            "actions": [
              {
                "selector": { "indexUid": "products", "id": "123" },
                "action": { "type": "pin", "position": 1 }
              }
            ]
          }
        ],
        "offset": 10,
        "limit": 2,
        "total": 1
      }
      """
    session.pushData(json)

    let params = DynamicSearchRulesQuery(
      offset: 10,
      limit: 2,
      filter: DynamicSearchRulesFilter(query: "black", active: true)
    )
    let result = try await client.listDynamicSearchRules(params: params)

    XCTAssertEqual(result.offset, 10)
    XCTAssertEqual(result.limit, 2)
    XCTAssertEqual(result.total, 1)
    XCTAssertEqual(result.results.first?.uid, "black-friday")
    XCTAssertEqual(result.results.first?.conditions.query?.words, "black friday")
    XCTAssertEqual(result.results.first?.actions.first?.action.type, .pin)
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "POST")
    XCTAssertEqual(session.nextDataTask.request?.url?.path, "/dynamic-search-rules")

    let body = try XCTUnwrap(session.nextDataTask.request?.httpBody)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    XCTAssertEqual(object["offset"] as? Int, 10)
    XCTAssertEqual(object["limit"] as? Int, 2)
    let filter = try XCTUnwrap(object["filter"] as? [String: Any])
    XCTAssertEqual(filter["query"] as? String, "black")
    XCTAssertEqual(filter["active"] as? Bool, true)
  }

  func testGetDynamicSearchRuleUsesGetAndDecodesRule() {
    let json = """
      {
        "uid": "black-friday",
        "description": null,
        "precedence": null,
        "active": true,
        "conditions": { "query": { "isEmpty": true } },
        "actions": [
          {
            "selector": { "id": "123" },
            "action": { "type": "pin", "position": 0 }
          }
        ]
      }
      """
    session.pushData(json)
    let expectation = XCTestExpectation(description: "Get a dynamic search rule")

    client.getDynamicSearchRule(uid: "black-friday") { result in
      switch result {
      case .success(let rule):
        XCTAssertEqual(rule.uid, "black-friday")
        XCTAssertTrue(rule.conditions.query?.isEmpty == true)
        XCTAssertNil(rule.actions.first?.selector.indexUid)
        XCTAssertEqual(rule.actions.first?.action.position, 0)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TESTS_TIME_OUT)
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "GET")
    XCTAssertEqual(session.nextDataTask.request?.url?.path, "/dynamic-search-rules/black-friday")
  }

  func testUpdateOrCreateDynamicSearchRuleUsesPatchBodyAndDecodesTask() async throws {
    let taskJSON = """
      {
        "taskUid": 147,
        "indexUid": ".meili_dsr",
        "status": "enqueued",
        "type": "dsrUpdate",
        "enqueuedAt": "2026-07-22T07:09:29.364Z"
      }
      """
    session.pushData(taskJSON, code: 202)

    let ruleParams = DynamicSearchRuleParams(
      description: "Black Friday rules",
      precedence: 10,
      active: true,
      conditions: DynamicSearchRuleConditions(
        time: DynamicSearchRuleTimeCondition(
          start: "2026-11-27T00:00:00Z",
          end: "2026-11-28T00:00:00Z"
        ),
        query: DynamicSearchRuleQueryCondition(isEmpty: true)
      ),
      actions: [
        DynamicSearchRuleAction(
          selector: DynamicSearchRuleSelector(indexUid: "products", id: "123"),
          action: DynamicSearchRuleActionPayload(position: 1)
        )
      ]
    )

    let task = try await client.updateOrCreateDynamicSearchRule(
      uid: "black-friday",
      ruleParams: ruleParams
    )

    XCTAssertEqual(task.taskUid, 147)
    XCTAssertEqual(task.type, .dynamicSearchRuleUpdate)
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "PATCH")
    XCTAssertEqual(session.nextDataTask.request?.url?.path, "/dynamic-search-rules/black-friday")

    let body = try XCTUnwrap(session.nextDataTask.request?.httpBody)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    XCTAssertEqual(object["precedence"] as? Int, 10)
    XCTAssertNil(object["priority"])
    let conditions = try XCTUnwrap(object["conditions"] as? [String: Any])
    XCTAssertNotNil(conditions["query"] as? [String: Any])
    XCTAssertNotNil(conditions["time"] as? [String: Any])
    let actions = try XCTUnwrap(object["actions"] as? [[String: Any]])
    let action = try XCTUnwrap(actions.first?["action"] as? [String: Any])
    XCTAssertEqual(action["type"] as? String, "pin")
    XCTAssertEqual(action["position"] as? Int, 1)
  }

  func testDeleteDynamicSearchRuleUsesDeleteAndDecodesTask() {
    let taskJSON = """
      {
        "taskUid": 148,
        "indexUid": ".meili_dsr",
        "status": "enqueued",
        "type": "dsrUpdate",
        "enqueuedAt": "2026-07-22T07:09:47.033Z"
      }
      """
    session.pushData(taskJSON, code: 202)
    let expectation = XCTestExpectation(description: "Delete a dynamic search rule")

    client.deleteDynamicSearchRule(uid: "black-friday") { result in
      switch result {
      case .success(let task):
        XCTAssertEqual(task.taskUid, 148)
        XCTAssertEqual(task.type, .dynamicSearchRuleUpdate)
      case .failure(let error):
        XCTFail("Unexpected error: \(error)")
      }
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: TESTS_TIME_OUT)
    XCTAssertEqual(session.nextDataTask.request?.httpMethod, "DELETE")
    XCTAssertEqual(session.nextDataTask.request?.url?.path, "/dynamic-search-rules/black-friday")
  }

  func testListDynamicSearchRulesWithoutParamsSendsEmptyObject() async throws {
    session.pushData("""
      { "results": [], "offset": 0, "limit": 20, "total": 0 }
      """)

    _ = try await client.listDynamicSearchRules()

    let body = try XCTUnwrap(session.nextDataTask.request?.httpBody)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    XCTAssertTrue(object.isEmpty)
  }

  func testUpdateOrCreateDynamicSearchRuleOmitsUnsetFields() async throws {
    session.pushData("""
      {
        "taskUid": 149,
        "indexUid": ".meili_dsr",
        "status": "enqueued",
        "type": "dsrUpdate",
        "enqueuedAt": "2026-07-22T07:10:00.000Z"
      }
      """, code: 202)

    _ = try await client.updateOrCreateDynamicSearchRule(
      uid: "black-friday",
      ruleParams: DynamicSearchRuleParams(description: "Updated description")
    )

    let body = try XCTUnwrap(session.nextDataTask.request?.httpBody)
    let object = try XCTUnwrap(JSONSerialization.jsonObject(with: body) as? [String: Any])
    XCTAssertEqual(object.count, 1)
    XCTAssertEqual(object["description"] as? String, "Updated description")
  }

  func testGetDynamicSearchRulePropagatesAPIError() async throws {
    session.pushData("""
      {
        "message": "Dynamic search rule `missing` not found.",
        "code": "dynamic_search_rule_not_found",
        "type": "invalid_request",
        "link": "https://docs.meilisearch.com/errors#dynamic_search_rule_not_found"
      }
      """, code: 404)

    do {
      _ = try await client.getDynamicSearchRule(uid: "missing")
      XCTFail("Expected the API error to be thrown")
    } catch let error as MeiliSearch.Error {
      switch error {
      case .meiliSearchApiError(_, let response, _, _):
        XCTAssertEqual(response?.code, "dynamic_search_rule_not_found")
      default:
        XCTFail("Unexpected Meilisearch error: \(error)")
      }
    }
  }

  func testDynamicSearchRuleActionTypePreservesUnknownValues() throws {
    let decoded: DynamicSearchRuleActionType = try decodeJSON(from: "\"futureAction\"")
    XCTAssertEqual(decoded, .unknown("futureAction"))

    let encoded = try JSONEncoder().encode(decoded)
    XCTAssertEqual(String(data: encoded, encoding: .utf8), "\"futureAction\"")
  }
}
