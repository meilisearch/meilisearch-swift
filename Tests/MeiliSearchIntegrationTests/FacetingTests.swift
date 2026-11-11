@testable import MeiliSearch
import XCTest

class FacetingTests: XCTestCase {
  func testSampledCountFacetingLifecycle() async throws {
    let client = try MeiliSearch(host: currentHost(), apiKey: "masterKey")
    let uid = "faceting_test"
    let index = client.index(uid)
    let creation = try await client.createIndex(uid: uid)
    _ = try await client.waitForTask(taskUid: creation.taskUid)
    do {
      for sortOrder: [String: Faceting.SortOrder] in [
        ["*": .sampledCount], ["*": .alpha, "genres": .sampledCount]
      ] {
        let settings = Faceting(maxValuesPerFacet: 2, sortFacetValuesBy: sortOrder)
        let update = try await index.updateFacetingSettings(settings)
        let completed = try await client.waitForTask(taskUid: update.taskUid)
        XCTAssertEqual(completed.status, .succeeded)
        let returned = try await index.getFacetingSettings()
        XCTAssertEqual(returned, settings)
        let allSettings = try await index.getSettings()
        XCTAssertEqual(allSettings.faceting, settings)
      }
      let reset = try await index.resetFacetingSettings()
      let completed = try await client.waitForTask(taskUid: reset.taskUid)
      XCTAssertEqual(completed.status, .succeeded)
      let defaults = try await index.getFacetingSettings()
      XCTAssertEqual(defaults, Faceting(maxValuesPerFacet: 100, sortFacetValuesBy: ["*": .alpha]))
    } catch {
      let deletion = try await client.deleteIndex(uid)
      _ = try await client.waitForTask(taskUid: deletion.taskUid)
      throw error
    }
    let deletion = try await client.deleteIndex(uid)
    _ = try await client.waitForTask(taskUid: deletion.taskUid)
  }
}
