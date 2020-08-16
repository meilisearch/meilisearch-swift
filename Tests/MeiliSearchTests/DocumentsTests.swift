@testable import MeiliSearch
import XCTest
import Foundation

private struct Movie: Codable, Equatable {

    let id: Int
    let title: String
    let comment: String?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case comment
    }
    init(id: Int, title: String, comment: String? = nil) {
        self.id = id
        self.title = title
        self.comment = comment
    }

}

private let movies = [
    Movie(id: 123, title: "Pride and Prejudice", comment: "A great book"),
    Movie(id: 456, title: "Le Petit Prince", comment: "A french book"),
    Movie(id: 2, title: "Le Rouge et le Noir", comment: "Another french book"),
    Movie(id: 1, title: "Alice In Wonderland", comment: "A weird book"),
    Movie(id: 1344, title: "The Hobbit", comment: "An awesome book"),
    Movie(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book"),
    Movie(id: 42, title: "The Hitchhiker's Gself.uide to the Galaxy"),
]


class DocumentsTests: XCTestCase {

    private var client: MeiliSearch!
    private var uid: String = ""
    
    override class func setUp() { // 1.
           super.setUp()
        // TODO: add getOrCreateIndex in this method but it does not work
    }

    override func setUp() {
        super.setUp()
        uid = "books_test"
        if client == nil {
            client = try! MeiliSearch(Config.default)
        }
        let expectation = XCTestExpectation(description: "Create index if it does not exist")
        self.client.deleteIndex(UID: self.uid) { result in
            switch result {
            case .success:
                self.client.getOrCreateIndex(UID: self.uid) { result in
                    switch result {
                    case .success:
                        expectation.fulfill()
                    case .failure(let error):
                        print(error)
                        expectation.fulfill()
                    }
                }
            case .failure:
                expectation.fulfill()
            }
        }
        
        self.wait(for: [expectation], timeout: 2.0)
    }

    func testAddAndGetDocuments() {
        let documents: Data = try! JSONEncoder().encode(movies)

        let expectation = XCTestExpectation(description: "Add or replace Movies document")
        self.client.addDocuments(
            UID: self.uid,
            documents: documents,
            primaryKey: nil
        ) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(Update(updateId: 0), update)
                expectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [expectation], timeout: 1.0)
        sleep(1)
        let getExpectation = XCTestExpectation(description: "Add or replace Movies document")
        self.client.getDocuments(
            UID: self.uid,
            limit: 20
        ) { (result: Result<[Movie], Swift.Error>) in

            switch result {
            case .success(let returnedMovies):
                XCTAssertEqual(movies, returnedMovies)
                getExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [getExpectation], timeout: 3.0)
    }

    func testGetOneDocumentAndFail() {
        
        let getExpectation = XCTestExpectation(description: "Get one document and fail")
        self.client.getDocument(
            UID: self.uid,
            identifier: "123456"
        ) { (result: Result<Movie, Swift.Error>) in
            switch result {
            case .success:
                XCTFail("Document has been found while it should not have")
            case .failure:
                getExpectation.fulfill()
            }
        }
        self.wait(for: [getExpectation], timeout: 3.0)
    }


     func testAddAndGetOneDocuments() {
         let movie: Movie = Movie(id: 10, title: "test", comment: "test movie")
         let documents: Data = try! JSONEncoder().encode([movie])

         let expectation = XCTestExpectation(description: "Add or replace Movies document")

         self.client.addDocuments(
             UID: self.uid,
             documents: documents,
             primaryKey: nil
         ) { result in
             switch result {
             case .success(let update):
                 XCTAssertEqual(Update(updateId: 0), update)
                 expectation.fulfill()
             case .failure(let error):
                 XCTFail(error.localizedDescription)
             }
         }
         self.wait(for: [expectation], timeout: 1.0)
         sleep(1)
         let getExpectation = XCTestExpectation(description: "Add or replace Movies document")
         self.client.getDocument(
             UID: self.uid,
             identifier: "10"
         ) { (result: Result<Movie, Swift.Error>) in

             switch result {
             case .success(let returnedMovie):
                 XCTAssertEqual(movie, returnedMovie)
                 getExpectation.fulfill()
             case .failure(let error):
                 XCTFail(error.localizedDescription)
             }
         }
         self.wait(for: [getExpectation], timeout: 3.0)
     }
    
     func testUpdateAndGetDocuments() {
         // FAILS
         let movie: Movie = Movie(id: 10, title: "test", comment: "test movie")
         let documents: Data = try! JSONEncoder().encode([movie])
        
         let expectation = XCTestExpectation(description: "Add or update Movies document")

         self.client.updateDocuments(
             UID: self.uid,
             documents: documents,
             primaryKey: nil
         ) { result in
             switch result {
             case .success(let update):
                 XCTAssertEqual(Update(updateId: 0), update)
                 expectation.fulfill()
             case .failure(let error):
                 XCTFail(error.localizedDescription)
             }
         }
         self.wait(for: [expectation], timeout: 1.0)
         sleep(1)
         let getExpectation = XCTestExpectation(description: "Add or update Movies document")
         self.client.getDocument(
             UID: self.uid,
             identifier: "10"
         ) { (result: Result<Movie, Swift.Error>) in

             switch result {
             case .success(let returnedMovie):
                 XCTAssertEqual(movie, returnedMovie)
                 getExpectation.fulfill()
             case .failure(let error):
                 XCTFail(error.localizedDescription)
             }
         }
         self.wait(for: [getExpectation], timeout: 3.0)
     }

     func testDeleteOneDocument(){
         let documents: Data = try! JSONEncoder().encode(movies)

         let expectation = XCTestExpectation(description: "Delete one Movie")
         self.client.addDocuments(
             UID: self.uid,
             documents: documents,
             primaryKey: nil
         ) { result in
             switch result {
             case .success(let update):
                 XCTAssertEqual(Update(updateId: 0), update)
                 expectation.fulfill()
             case .failure:
                 XCTFail("Failed to add or replace Movies document")
             }
         }
         self.wait(for: [expectation], timeout: 1.0)
         sleep(1)
         let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
         self.client.deleteDocument(UID: self.uid, identifier: "42") { (result: Result<Update, Swift.Error>) in
             switch result {
             case .success(let update):
                 XCTAssertEqual(Update(updateId: 1), update)
                 deleteExpectation.fulfill()
             case .failure(let error):
                 XCTFail(error.localizedDescription)
             }
         }
         self.wait(for: [deleteExpectation], timeout: 3.0)
        
         sleep(1)
         let getExpectation = XCTestExpectation(description: "Add or update Movies document")
         self.client.getDocument(
             UID: self.uid,
             identifier: "10"
         ) { (result: Result<Movie, Swift.Error>) in
             switch result {
             case .success:
                 XCTFail("Movie should not exist")
             case .failure:
                 getExpectation.fulfill()
             }
         }
         self.wait(for: [getExpectation], timeout: 3.0)
        
     }
    
        
    func testDeleteAllDocuments(){
        let documents: Data = try! JSONEncoder().encode(movies)

        let expectation = XCTestExpectation(description: "Delete one Movie")
        self.client.addDocuments(
            UID: self.uid,
            documents: documents,
            primaryKey: nil
        ) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(Update(updateId: 0), update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to add or replace Movies document")
            }
        }
        self.wait(for: [expectation], timeout: 1.0)
        sleep(1)
        let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
        self.client.deleteAllDocuments(UID: self.uid) { (result: Result<Update, Swift.Error>) in
            switch result {
            case .success(let update):
                XCTAssertEqual(Update(updateId: 1), update)
                deleteExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [deleteExpectation], timeout: 3.0)
       
        sleep(1)
        let getExpectation = XCTestExpectation(description: "Add or update Movies document")
        self.client.getDocuments(
            UID: self.uid,
            limit: 20
        ) { (result: Result<[Movie], Swift.Error>) in
            switch result {
            case .success(let results):
                XCTAssertEqual([], results)
                getExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [getExpectation], timeout: 3.0)
       
    }

    func testDeleteBatchDocuments(){
        let documents: Data = try! JSONEncoder().encode(movies)

        let expectation = XCTestExpectation(description: "Delete one Movie")
        self.client.addDocuments(
            UID: self.uid,
            documents: documents,
            primaryKey: nil
        ) { result in
            switch result {
            case .success(let update):
                XCTAssertEqual(Update(updateId: 0), update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to add or replace Movies document")
            }
        }
        self.wait(for: [expectation], timeout: 1.0)
        sleep(1)
        let deleteExpectation = XCTestExpectation(description: "Delete one Movie")
        self.client.deleteBatchDocuments(UID: self.uid, documentsUID: [2,1,4]) { (result: Result<Update, Swift.Error>) in
            switch result {
            case .success(let update):
                XCTAssertEqual(Update(updateId: 1), update)
                deleteExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [deleteExpectation], timeout: 3.0)
       
        sleep(1)
        let getExpectation = XCTestExpectation(description: "Add or update Movies document")
        self.client.getDocuments(
            UID: self.uid,
            limit: 20
        ) { (result: Result<[Movie], Swift.Error>) in
            switch result {
            case .success(let results):
                let filteredMovies : [Movie] = movies.filter { $0.id != 2 || $0.id != 4 || $0.id != 1 }
                XCTAssertEqual(filteredMovies, results)
                getExpectation.fulfill()
            case .failure(let error):
                XCTFail(error.localizedDescription)
            }
        }
        self.wait(for: [getExpectation], timeout: 3.0)
       
    }
    
    static var allTests = [
        ("testAddAndGetDocuments", testAddAndGetDocuments),
        ("testGetOneDocumentAndFail", testGetOneDocumentAndFail),
        ("testAddAndGetOneDocuments", testAddAndGetOneDocuments),
        ("testUpdateAndGetDocuments", testUpdateAndGetDocuments),
        ("testDeleteOneDocument", testDeleteOneDocument),
        ("testDeleteAllDocuments", testDeleteAllDocuments),
        ("testDeleteBatchDocuments", testDeleteBatchDocuments)
    ]

}
