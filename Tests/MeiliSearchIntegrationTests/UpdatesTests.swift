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

private let movies: [Movie] = [
  Movie(id: 123, title: "Pride and Prejudice", comment: "A great book"),
  Movie(id: 456, title: "Le Petit Prince", comment: "A french book"),
  Movie(id: 2, title: "Le Rouge et le Noir", comment: "Another french book"),
  Movie(id: 1, title: "Alice In Wonderland", comment: "A weird book"),
  Movie(id: 1344, title: "The Hobbit", comment: "An awesome book"),
  Movie(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book"),
  Movie(id: 42, title: "The Hitchhiker's Guide to the Galaxy"),
  Movie(id: 1844, title: "A Moreninha", comment: "A Book from Joaquim Manuel de Macedo")
]

class UpdatesTests: XCTestCase {

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
    let expectation = XCTestExpectation(description: "Create index if it does not exist")

    self.client.deleteIndex(uid) { _ in
      self.client.getOrCreateIndex(uid: self.uid) { result in
        switch result {
        case .success:
          expectation.fulfill()
        case .failure(let error):
          print(error)
          XCTFail()
        }
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testGetUpdateStatus() {

    let expectation = XCTestExpectation(description: "Get update status for transaction")
    let movie: Movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try! JSONEncoder().encode([movie])

    self.index.addDocuments(documents: documents, primaryKey: nil) { result in
      switch result {
      case .success(let update):
        self.index.getUpdate(update.updateId) { (result: Result<Task.Result, Swift.Error>)  in
          switch result {
          case .success(let update):
            XCTAssertEqual("DocumentsAddition", update.type.name)
          case .failure(let error):
            print(error)
            XCTFail()
          }
          expectation.fulfill()
        }
      case .failure:
        XCTFail("Failed to update movie index")
      }
    }

    self.wait(for: [expectation], timeout: 10.0)

  }

  func testGetAllUpdatesStatus() {

    let expectation = XCTestExpectation(description: "Get update status for all transaction")
    let jsonEncoder = JSONEncoder()
    for index in 0...10 {
      let movie: Movie = Movie(id: index, title: "test\(index)", comment: "test movie\(index)")
      let documents: Data = try! jsonEncoder.encode([movie])
      self.index.addDocuments(documents: documents, primaryKey: nil) { _ in }
    }

    self.index.getAllUpdates { (result: Result<[Task.Result], Swift.Error>)  in
      switch result {
      case .success(let updates):
        updates.forEach { (update: Task.Result) in
          XCTAssertEqual("DocumentsAddition", update.type.name)
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
      expectation.fulfill()
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testWaitForPendingUpdateSuccessDefault () {
    let expectation = XCTestExpectation(description: "Wait for pending update with default options")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update) { result in
          switch result {
          case .success(let update):
            XCTAssertEqual(Task.Status, Task.Status.processed)
          case .failure(let error):
            XCTFail(error.localizedDescription)
          }
          expectation.fulfill()
        }
      case .failure(let error):
        XCTFail(error.localizedDescription)
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testAddDocumentWithNoPrimaryKey () {
    let expectation = XCTestExpectation(description: "Add documents with no primary key and check update error")

    struct WrongMovie: Codable, Equatable {
      let id: Int?
      let title: String

      init(id: Int? = nil, title: String) {
        self.id = id
        self.title = title
      }

    }
    let wrongMovies: [WrongMovie] = [
      WrongMovie(title: "Pride and Prejudice")
    ]

    self.index.addDocuments(
      documents: wrongMovies
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update) { result in
          switch result {
          case .success(let update):
            XCTAssertEqual(Task.Status, Task.Status.failed)
            XCTAssertEqual(update.error?.code, "primary_key_inference_failed")
            XCTAssertNotNil(update.error?.type)
            XCTAssertNotNil(update.error?.link)
            XCTAssertNotNil(update.error?.message)

          case .failure(let error):
            XCTFail(error.localizedDescription)
          }
          expectation.fulfill()
        }
      case .failure(let error):
        XCTFail(error.localizedDescription)
      }
    }

    self.wait(for: [expectation], timeout: 10.0)
  }

  func testWaitForPendingUpdateSuccessEmptyOptions () {
    let expectation = XCTestExpectation(description: "Wait for pending update with default options")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update, options: WaitOptions()) { result in
          switch result {
          case .success(let update):
            XCTAssertEqual(Task.Status, Task.Status.processed)
          case .failure(let error):
            XCTFail(error.localizedDescription)
          }
          expectation.fulfill()
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testWaitForPendingUpdateSuccessWithOptions () {
    let expectation = XCTestExpectation(description: "Wait for pending update with default options")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update, options: WaitOptions(timeOut: 5, interval: 2)) { result in
          switch result {
          case .success(let update):
            XCTAssertEqual(Task.Status, Task.Status.processed)
          case .failure(let error):
            XCTFail(error.localizedDescription)
          }
          expectation.fulfill()
        }
      case .failure(let error):
        XCTFail(error.localizedDescription)
      }
    }
    self.wait(for: [expectation], timeout: 5.0)
  }

  func testWaitForPendingUpdateSuccessWithIntervalZero () {
    let expectation = XCTestExpectation(description: "Wait for pending update with default options")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update, options: WaitOptions(timeOut: 5, interval: 0)) { result in
          switch result {
          case .success(let update):
            XCTAssertEqual(Task.Status, Task.Status.processed)
          case .failure(let error):
            XCTFail(error.localizedDescription)
          }
          expectation.fulfill()
        }
      case .failure(let error):
        XCTFail(error.localizedDescription)
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testWaitForPendingUpdateTimeOut () {
    let expectation = XCTestExpectation(description: "Wait for pending update with default options")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let update):
        XCTAssertEqual(Update(updateId: 0), update)
        self.index.waitForPendingUpdate(update: update, options: WaitOptions(timeOut: 0, interval: 2)) { result in
          switch result {
          case .success:
            XCTFail("waitForPendingUpdate should not have had the time for a second call")
          case .failure(let error):
            print(error.localizedDescription)
            switch error {
            case MeiliSearch.Error.timeOut(let double):
              XCTAssertEqual(double, 0.0)
            default:
              XCTFail("MeiliSearch TimeOut error should have been thrown")
            }
          }
          expectation.fulfill()
        }
      case .failure(let error):
        print(error)
        XCTFail()
      }
    }

    self.wait(for: [expectation], timeout: 5.0)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
