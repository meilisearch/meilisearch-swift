@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
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

class DocumentsTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private var session: URLSessionProtocol!
  private let uid: String = "books_test"

  override func setUp() {
    super.setUp()
    session = URLSession(configuration: .ephemeral)
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
    let expectation = XCTestExpectation(description: "Create index if it does not exist")
    self.client.createIndex(uid: uid) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success:
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddDocuments() {
    let expectation = XCTestExpectation(description: "Add documents")

    // Add document
    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("documentAddition", task.type)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            if let details = task.details {
              if let indexedDocuments = details.indexedDocuments {
                XCTAssertEqual(8, indexedDocuments)
              } else {
                XCTFail("IndexedDocuments field should not be nil")
              }
            } else {
              XCTFail("IndexedDocuments field should exists in details field of task")
            }

            if let details = task.details {
              if let receivedDocuments = details.receivedDocuments {
                XCTAssertEqual(8, receivedDocuments)
              } else {
                XCTFail("receivedDocuments field should not be nil")
              }
            } else {
              XCTFail("receivedDocuments field should exists in details field of task")
            }
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddDocumentsWithNoPrimaryKey() {
    let expectation = XCTestExpectation(description: "Add documents with no primary key")
    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual("documentAddition", task.type)
            XCTAssertEqual(Task.Status.succeeded, task.status)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to fetch documents")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }

    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetDocumentsWithParameters() {
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: movies,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAddition", task.type)
            self.index.getDocuments(
              options: GetParameters(offset: 1, limit: 1, attributesToRetrieve: ["id", "title"])
            ) { (result: Result<[Movie], Swift.Error>) in
              switch result {
              case .success(let returnedMovies):
                let returnedMovie = returnedMovies[0]
                XCTAssertEqual(returnedMovies.count, 1)
                XCTAssertEqual(returnedMovie.id, 123)
                XCTAssertEqual(returnedMovie.title, "Pride and Prejudice")
                XCTAssertEqual(returnedMovie.comment, nil)
                expectation.fulfill()
              case .failure:
                XCTFail("Failed to fetch documents")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testGetOneDocumentAndFail() {
    let expectation = XCTestExpectation(description: "Get one document and fail")
    self.index.getDocument("123456") { (result: Result<Movie, Swift.Error>) in
      switch result {
      case .success:
        XCTFail("Document has been found while it should not have")
        expectation.fulfill()
      case .failure:
        expectation.fulfill()
      }

    }
    self.wait(for: [expectation], timeout: 3.0)
  }

  func testAddAndGetOneDocumentWithIntIdentifierAndSucceed() {
    let movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try! JSONEncoder().encode([movie])
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAddition", task.type)
            self.index.getDocument(10
            ) { (result: Result<Movie, Swift.Error>) in
              switch result {
              case .success(let returnedMovie):
                XCTAssertEqual(movie, returnedMovie)
                expectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to fetch one document")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add documents")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testAddAndGetOneDocument() {
    let movie = Movie(id: 10, title: "test", comment: "test movie")
    let documents: Data = try! JSONEncoder().encode([movie])
    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentAddition", task.type)
            self.index.getDocument("10"
            ) { (result: Result<Movie, Swift.Error>) in
              switch result {
              case .success(let returnedMovie):
                XCTAssertEqual(movie, returnedMovie)
                expectation.fulfill()
              case .failure(let error):
                dump(error)
                XCTFail("Failed to fetch one document")
                expectation.fulfill()
              }
            }
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to add one document")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testUpdateDocument() {
    let identifier: Int = 1844
    let movie: Movie = movies.first(where: { (movie: Movie) in movie.id == identifier })!
    let documents: Data = try! JSONEncoder().encode([movie])

    let expectation = XCTestExpectation(description: "Add or update Movies document")

    self.index.updateDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentPartial", task.type)
            expectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to update one document")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteOneDocument() {
    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Delete one Movie")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
    self.index.deleteDocument("42") { (result: Result<Task, Swift.Error>) in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type)
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete one document")
        deleteExpectation.fulfill()
      }
    }
    self.wait(for: [deleteExpectation], timeout: 3.0)
  }

  func testDeleteAllDocuments() {
    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Add documents")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete all documents")
    self.index.deleteAllDocuments { (result: Result<Task, Swift.Error>) in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("clearAll", task.type)
            if let details = task.details {
              if let deletedDocuments = details.deletedDocuments {
                XCTAssertEqual(9, deletedDocuments)
              } else {
                XCTFail("deletedDocuments field should not be nil")
                deleteExpectation.fulfill()
              }
            } else {
              XCTFail("deletedDocuments field should exists in details field of task")
              deleteExpectation.fulfill()
            }
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete all documents")
        deleteExpectation.fulfill()
      }
    }

    self.wait(for: [deleteExpectation], timeout: TESTS_TIME_OUT)
  }

  func testDeleteBatchDocuments() {
    let documents: Data = try! JSONEncoder().encode(movies)

    let expectation = XCTestExpectation(description: "Add documents")
    self.index.addDocuments(
      documents: documents,
      primaryKey: nil
    ) { result in
      switch result {
      case .success:
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)

    let deleteExpectation = XCTestExpectation(description: "Delete batch movies")
    let idsToDelete: [Int] = [2, 1, 4]

    self.index.deleteBatchDocuments(idsToDelete) { (result: Result<Task, Swift.Error>) in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success(let task):
            XCTAssertEqual(Task.Status.succeeded, task.status)
            XCTAssertEqual("documentDeletion", task.type)
            deleteExpectation.fulfill()
          case .failure:
            XCTFail("Failed to wait for task")
            deleteExpectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Failed to delete documents")
        deleteExpectation.fulfill()
      }
    }
    self.wait(for: [deleteExpectation], timeout: TESTS_TIME_OUT)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
