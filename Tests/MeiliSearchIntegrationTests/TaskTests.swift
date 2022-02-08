@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_try
private struct Movie: Codable, Equatable {
  let id: Int
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
  }
}

class TasksTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"

  // MARK: Setup

  override func setUp() {
    super.setUp()
    session = URLSession(configuration: .ephemeral)
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
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
    self.wait(for: [createExpectation], timeout: 5.0)
  }

  func testGetTaskIndex() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")
    let movie = Movie(id: 1, title: "test", comment: "test movie")

    self.index.addDocuments(documents: [movie], primaryKey: nil) { result in
      switch result {
      case .success(let task):
        self.index.getTask(taskUid: task.uid) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type, "documentAddition")
            addDocExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            addDocExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: 10.0)
  }

  func testGetTasksIndex() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")

    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success:
        addDocExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: 10.0)

    let expectation = XCTestExpectation(description: "Get all tasks of an index")
    self.index.getTasks { (result: Result<Results<Task>, Swift.Error>)  in
      switch result {
      case .success(let tasks):
        // Only one because index has been deleted and recreated
        XCTAssertEqual(tasks.results.count, 1)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get tasks")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetTaskClient() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.getTask(taskUid: task.uid) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type, "indexCreation")
            addDocExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            addDocExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: 10.0)
  }

  func testGetTasksClient() {
    let addDocExpectation = XCTestExpectation(description: "Add documents")

    addDocuments(client: self.client, uid: self.uid, primaryKey: nil) { result in
      switch result {
      case .success:
        addDocExpectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to create index")
        addDocExpectation.fulfill()
      }
    }
    self.wait(for: [addDocExpectation], timeout: 10.0)

    let expectation = XCTestExpectation(description: "Get all tasks of an index")
    self.client.getTasks { (result: Result<Results<Task>, Swift.Error>)  in
      switch result {
      case .success(let tasks):
        XCTAssertNotNil(tasks.results)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to get tasks")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testWaitForTask() {
    let createIndexExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task, options: WaitOptions(timeOut: 1, interval: 0.5)) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type, "indexCreation")
            createIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            createIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        createIndexExpectation.fulfill()
      }
    }
    self.wait(for: [createIndexExpectation], timeout: 10.0)
  }

  func testWaitForTaskUid() {
    let createIndexExpectation = XCTestExpectation(description: "Add documents")

    self.client.createIndex(uid: self.uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(taskUid: task.uid, options: WaitOptions(timeOut: 1, interval: 0.5)) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(task.type, "indexCreation")
            createIndexExpectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Could not get task")
            createIndexExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        createIndexExpectation.fulfill()
      }
    }
    self.wait(for: [createIndexExpectation], timeout: 10.0)
  }
}
