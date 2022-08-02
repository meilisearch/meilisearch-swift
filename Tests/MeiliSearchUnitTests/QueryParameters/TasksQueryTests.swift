@testable import MeiliSearch

import XCTest

class TasksQueryTests: XCTestCase {
  func testRenderedQuery() {
    let data: [[String: TasksQuery]] = [
      ["?limit=2": TasksQuery(limit: 2)],
      ["?from=99&limit=2&type=name,title": TasksQuery(limit: 2, from: 99, types: ["name", "title"])],
      ["?limit=2": TasksQuery(limit: 2, next: nil)],
      ["?from=2": TasksQuery(from: 2)],
      ["?indexUid=my-index,123": TasksQuery(indexUid: ["my-index", "123"])],
      ["?limit=10&next=0": TasksQuery(limit: 10, next: 0)],
      ["": TasksQuery()]
    ]

    data.forEach { dict in
      XCTAssertEqual(dict.first?.value.toQuery(), dict.first?.key)
    }
  }
}
