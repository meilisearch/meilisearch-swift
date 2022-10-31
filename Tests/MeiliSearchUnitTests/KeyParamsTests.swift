@testable import MeiliSearch

import XCTest

class KeyParamsTests: XCTestCase {
  func testInitializer() {
    let keyParams1 = KeyParams(actions: ["action1"], indexes: ["index1"], expiresAt: nil)
    XCTAssertEqual(keyParams1.actions, ["action1"])
    XCTAssertEqual(keyParams1.indexes, ["index1"])
    XCTAssertNil(keyParams1.expiresAt)
    XCTAssertNil(keyParams1.description)
    XCTAssertNil(keyParams1.name)
    XCTAssertNil(keyParams1.uid)
    
    let keyParams2 = KeyParams(description: "The default search key", name: "Default Search Key", uid: "74c9c733-3368-4738-bbe5-1d18a5fecb37", actions: ["action1"], indexes: ["index1"], expiresAt: "2021-08-11T10:00:00Z")
    XCTAssertEqual(keyParams2.actions, ["action1"])
    XCTAssertEqual(keyParams2.indexes, ["index1"])
    XCTAssertEqual(keyParams2.expiresAt, "2021-08-11T10:00:00Z")
    XCTAssertEqual(keyParams2.description, "The default search key")
    XCTAssertEqual(keyParams2.name, "Default Search Key")
    XCTAssertEqual(keyParams2.uid, "74c9c733-3368-4738-bbe5-1d18a5fecb37")
  }
}
