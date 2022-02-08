@testable import MeiliSearch
import XCTest

// swiftlint:disable force_try
class IndexesTests: XCTestCase {
  private var client: MeiliSearch!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"
  private var index: Indexes!

  override func setUp() {
    super.setUp()

    if client == nil {
      session = URLSession(configuration: .ephemeral)
      client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    }
    index = self.client.index(self.uid)

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
              dump(error)
              asyncDeletegroup.leave()
            }
          }
        }
        getIndexesExp.fulfill()
      case .failure(let error):
        dump(error)
        getIndexesExp.fulfill()
      }
    }
    self.wait(for: [getIndexesExp], timeout: 20.0)
  }

  func testCreateIndex() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexCreation", task.type)
            XCTAssertEqual(task.status, Task.Status.succeeded)
            createExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            createExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create an index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)
  }

  func testCreateIndexThatAlreadyExists() {
    let deleteException = XCTestExpectation(description: "Delete Movies index")
    deleteIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        deleteException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        deleteException.fulfill()
      }
    }
    self.wait(for: [deleteException], timeout: 20.0)

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid ) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual("indexCreation", task.type)
        XCTAssertEqual(task.status, Task.Status.succeeded)
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)

    let create2ndIndexExpectation = XCTestExpectation(description: "Create Movies index that already exists and fail")
    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexCreation", task.type)
            XCTAssertEqual(task.status, Task.Status.failed)
            if let error = task.error {
              XCTAssertEqual(error.code, "index_already_exists")
            } else {
              XCTFail("Failed: Error code should be index_already_exists")
            }
            create2ndIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            create2ndIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create an index")
        create2ndIndexExpectation.fulfill()
      }
    }
    self.wait(for: [create2ndIndexExpectation], timeout: 20.0)

  }

  func testGetIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid ) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)

    let getIndexExpectation = XCTestExpectation(description: "Get index")

    self.client.getIndex(self.uid) { result in
      switch result {
      case .success(let index):
        let stubIndex = self.client.index(self.uid)
        XCTAssertEqual(stubIndex.uid, index.uid)
        getIndexExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get index")
      }
    }

    self.wait(for: [getIndexExpectation], timeout: 20.0)
  }

  func testGetIndexes() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)

    let expectation = XCTestExpectation(description: "Load indexes")

    self.client.getIndexes { result in
      switch result {
      case .success(let indexes):
        XCTAssertEqual(1, indexes.count)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get all Indexes")
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testUpdateIndexName() {
    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)

    // This tests should tests primary key when they are added to this function
    let updateExpectation = XCTestExpectation(description: "Update movie index")
    self.client.updateIndex(uid: self.uid, primaryKey: "random") { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("indexUpdate", task.type)
            XCTAssertEqual(task.status, Task.Status.succeeded)
            if let details = task.details {
              if let primaryKey = details.primaryKey {
                XCTAssertEqual("random", primaryKey)
              } else {
                XCTFail("Primary key should not be nil")
              }
            } else {
              XCTFail("Primary key should exists in details field of task")
            }
            updateExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            updateExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update index")
        updateExpectation.fulfill()
      }
    }
    self.wait(for: [updateExpectation], timeout: 20.0)
  }

  func testDeleteIndex() {

    let createExpectation = XCTestExpectation(description: "Create Movies index")
    createGenericIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success:
        createExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        createExpectation.fulfill()
      }
    }
    self.wait(for: [createExpectation], timeout: 20.0)

    let deleteException = XCTestExpectation(description: "Delete Movies index")
    deleteIndex(client: self.client, uid: self.uid) { result in
      switch result {
      case .success(let task):
        XCTAssertEqual("indexDeletion", task.type)
        XCTAssertEqual(task.status, Task.Status.succeeded)
        deleteException.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        deleteException.fulfill()
      }
    }
    self.wait(for: [deleteException], timeout: 20.0)
  }

    // TODO: remove
  // func testGetOrCreateIndex() {
  //   let expectation = XCTestExpectation(description: "Get or create Movies index")

  //   self.client.getOrCreateIndex(uid: self.uid) { result in
  //     switch result {
  //     case .success(let index):
  //       let stubIndex = self.client.index(self.uid)
  //       XCTAssertEqual(stubIndex.uid, index.uid)
  //       expectation.fulfill()
  //     case .failure(let error):
//    dump(error)
  //       XCTFail("Failed to get or create Movies index")
  //     }
  //   }

  //   self.wait(for: [expectation], timeout: 20.0)
  // }

  // func testGetOrCreateIndexAlreadyExists() {
  //   let expectation = XCTestExpectation(description: "Get or create a non existing uid")

  //   self.client.getOrCreateIndex(uid: self.uid) { result in
  //     switch result {
  //     case .success(let index):
  //       let stubIndex = self.client.index(self.uid)
  //       XCTAssertEqual(stubIndex.uid, index.uid)
  //       expectation.fulfill()
  //     case .failure(let error):
  //       XCTFail("Failed to get or create Movies index, error: \(error)")
  //     }
  //   }

  //   self.wait(for: [expectation], timeout: 20.0)

  //   sleep(2)

  //   let secondExpectation = XCTestExpectation(description: "Get or create an existing index")

  //   self.client.getOrCreateIndex(uid: self.uid) { result in
  //     switch result {
  //     case .success(let index):
  //       let stubIndex = self.client.index(self.uid)
  //       XCTAssertEqual(stubIndex.uid, index.uid)
  //       secondExpectation.fulfill()
  //     case .failure(let error):
  //       XCTFail("Failed to get or create an existing index, error: \(error)")
  //     }
  //   }

  //   self.wait(for: [secondExpectation], timeout: 20.0)
  // }

}
// swiftlint:enable force_try
