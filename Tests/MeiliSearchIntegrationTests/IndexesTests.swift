@testable import MeiliSearch
import XCTest

// swiftlint:disable force_try
class IndexesTests: XCTestCase {

  private var client: MeiliSearch!
  private let uid: String = "books_test"

  override func setUp() {
    super.setUp()

    if client == nil {
      client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey")
    }
    let getIndexesExp = XCTestExpectation(description: "Try to get all indexes")
    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        let asyncDeletegroup = DispatchGroup()
        for index in indexes {
          asyncDeletegroup.enter()
          self.client.deleteIndex(index.uid) { res in
            switch res {
            case .success:
              asyncDeletegroup.leave()
            case .failure(let error):
              print(error.localizedDescription)
              asyncDeletegroup.leave()
            }
          }
        }
        getIndexesExp.fulfill()
      case .failure(let error):
        print(error.localizedDescription)
        getIndexesExp.fulfill()
      }
    }
    self.wait(for: [getIndexesExp], timeout: 5.0)

  }

  func testCreateIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        createExpectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }
    }

    self.wait(for: [createExpectation], timeout: 5.0)
  }

  func testCreateIndexThatAlreadyExists() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure:
        XCTFail("Failed to create Movies index")
      }
    }
    self.wait(for: [createExpectation], timeout: 5.0)

    let create2ndIndexExpectation = XCTestExpectation(description: "Create Movies index that already exists and fail")
    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success:
        XCTFail("Movie index created when it should have not be possible")
      case .failure(let error):
        XCTAssertNotNil(error.localizedDescription)
        switch error {
        case MeiliSearch.Error.meiliSearchApiError(let message, let msErrorResponse, let statusCode, let url):
          XCTAssertNotNil(message)
          XCTAssertNotNil(msErrorResponse)
          XCTAssertNotNil(statusCode)
          XCTAssertNotNil(url)
          if let msError = msErrorResponse as MeiliSearch.MSErrorResponse? {
            XCTAssertEqual(msError.errorCode, "index_already_exists")
            XCTAssertNotNil(msError.message)
            XCTAssertNotNil(msError.errorLink)
            XCTAssertNotNil(msError.errorType)
          } else {
            XCTFail("Error body should be of type msErrorResponse")
          }
        default:
          XCTFail("Index already exists error should be an MeiliSearch Api Error")
        }
      }
      create2ndIndexExpectation.fulfill()
    }
    self.wait(for: [create2ndIndexExpectation], timeout: 5.0)
  }

  func testGetOrCreateIndex() {

    let expectation = XCTestExpectation(description: "Get or create Movies index")

    self.client.getOrCreateIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get or create Movies index")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetOrCreateIndexAlreadyExists() {

    let expectation = XCTestExpectation(description: "Get or create a non existing uid")

    self.client.getOrCreateIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Failed to get or create Movies index, error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

    sleep(2)

    let secondExpectation = XCTestExpectation(description: "Get or create an existing index")

    self.client.getOrCreateIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        secondExpectation.fulfill()
      case .failure(let error):
        XCTFail("Failed to get or create an existing index, error: \(error)")
      }
    }

    self.wait(for: [secondExpectation], timeout: 5.0)

  }

  func testGetIndex() {

    let expectation = XCTestExpectation(description: "Get or create a non existing uid")

    self.client.getOrCreateIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        expectation.fulfill()
      case .failure(let error):
        XCTFail("Failed to get or create Movies index, error: \(error)")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

    let getIndexExpectation = XCTestExpectation(description: "Get index")

    self.client.getIndex(self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        getIndexExpectation.fulfill()
      case .failure:
        XCTFail("Failed to get index")
      }

    }

    self.wait(for: [getIndexExpectation], timeout: 5.0)

  }

  func testGetIndexes() {

    let createIndexExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        createIndexExpectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }
    }

    self.wait(for: [createIndexExpectation], timeout: 5.0)

    sleep(1)

    let expectation = XCTestExpectation(description: "Load indexes")

    self.client.getIndexes { result in

      switch result {
      case .success(let indexes):
        let stubIndexes = [self.client.index(self.uid)]
        XCTAssertEqual(stubIndexes.count, indexes.count)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get all Indexes")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetEmptyIndexes() {

    let expectation = XCTestExpectation(description: "Load indexes")

    self.client.getIndexes { result in

      switch result {
      case .success(let indexes):
        XCTAssertEqual(0, indexes.count)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get all Indexes")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testUpdateIndexName() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        createExpectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }
    }

    self.wait(for: [createExpectation], timeout: 5.0)

    // This tests should tests primary key when they are added to this function
    let updateExpectation = XCTestExpectation(description: "Update movie index")
    self.client.updateIndex(uid: self.uid, primaryKey: "random") { result in
      switch result {
      case .success(let index):
        XCTAssertEqual("random", index.primaryKey)
        XCTAssertEqual(self.uid, index.uid)
      updateExpectation.fulfill()
      case .failure:
        XCTFail("Failed to update movie index")
      }
    }
    self.wait(for: [updateExpectation], timeout: 5.0)
  }

  func testDeleteIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        createExpectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies index")
      }
    }

    self.wait(for: [createExpectation], timeout: 5.0)

    let expectation = XCTestExpectation(description: "Delete Movies index")

    self.client.deleteIndex(self.uid) { result in

      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete Movies index")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }
}
// swiftlint:enable force_try
