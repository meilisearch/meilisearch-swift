@testable import MeiliSearch
import XCTest
import Foundation

private struct Movie: Codable, Equatable {

    let id: Int
    let title: String
    let overview: String
    let releaseDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case releaseDate = "release_date"
    }

}

class DocumentsTests: XCTestCase {

    private var client: MeiliSearch!
    
    override class func setUp() { // 1.
           super.setUp()
        // TODO: add getOrCreateIndex in this method but it does not work
    }

    override func setUp() {
        super.setUp()

        if client == nil {
            client = try! MeiliSearch(Config.default)
        }

        let expectation = XCTestExpectation(description: "Create index if it does not exist")

        self.client.getOrCreateIndex(UID: "books_test") { result in
            switch result {
            case .success(let index):
                print("INDEX")
                print(index)
                expectation.fulfill()
            case .failure(let error):
                print(error)
                print("ERROR")
//                XCTFail("Failed to create Index")
                expectation.fulfill()
            }
        }
        self.wait(for: [expectation], timeout: 2.0)
        
    }

    func testAddDocuments() {

        //Prepare the mock server

        let jsonString = """
        {"updateId":0}
        """

        let decoder: JSONDecoder = JSONDecoder()
        let jsonData = jsonString.data(using: .utf8)!
        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

        // Start the test with the mocked server

        let uid: String = "books_test"

        let documentJsonString = """
        [{
            "id": 287947,
            "title": "Shazam",
            "poster": "https://image.tmdb.org/t/p/w1280/xnopI5Xtky18MPhK40cZAGAOVeV.jpg",
            "overview": "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
            "release_date": "2019-03-23"
        }]
        """

        let primaryKey: String = ""

        let documents: Data = documentJsonString.data(using: .utf8)!

        let expectation = XCTestExpectation(description: "Add or replace Movies document")

        self.client.addDocuments(
            UID: uid,
            documents: documents,
            primaryKey: primaryKey) { result in

            switch result {
            case .success(let update):
                XCTAssertEqual(stubUpdate, update)
                expectation.fulfill()
            case .failure:
                XCTFail("Failed to add or replace Movies document")
            }

        }

        self.wait(for: [expectation], timeout: 1.0)

    }

//    func testUpdateDocuments() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        {"updateId":0}
//        """
//
//        let decoder: JSONDecoder = JSONDecoder()
//        let jsonData = jsonString.data(using: .utf8)!
//        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)
//
//        // Start the test with the mocked server
//
//        let uid: String = "books_test"
//
//        let documentJsonString = """
//        [{
//            "id": 287947,
//            "title": "Shazam ⚡️"
//        }]
//        """
//
//        let primaryKey: String = "movieskud"
//
//        let documents: Data = documentJsonString.data(using: .utf8)!
//
//        let expectation = XCTestExpectation(description: "Add or update Movies document")
//
//        self.client.updateDocuments(
//            UID: uid,
//            documents: documents,
//            primaryKey: primaryKey) { result in
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(stubUpdate, update)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to add or update Movies document")
//            }
//
//        }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }
//
//    func testGetDocument() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        {
//            "id": 25684,
//            "title": "American Ninja 5",
//            "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
//            "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja.",
//            "release_date": "2020-04-04T19:59:49.259572Z"
//        }
//        """
//
//        let decoder: JSONDecoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
//        let data = jsonString.data(using: .utf8)!
//        let stubMovie: Movie = try! decoder.decode(Movie.self, from: data)
//
//        // Start the test with the mocked server
//
//        let uid: String = "books_test"
//        let identifier: String = "25684"
//
//        let expectation = XCTestExpectation(description: "Get Movies document")
//
//      self.client.getDocument(UID: uid, identifier: identifier) { (result: Result<Movie, Swift.Error>) in
//
//            switch result {
//            case .success(let movie):
//                XCTAssertEqual(stubMovie, movie)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to get Movies document")
//            }
//
//      }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }
//
//    func testGetDocuments() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        [{
//            "id": 25684,
//            "release_date": "2020-04-04T19:59:49.259572Z",
//            "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
//            "title": "American Ninja 5",
//            "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja."
//        },{
//            "id": 468219,
//            "title": "Dead in a Week (Or Your Money Back)",
//            "release_date": "2020-04-04T19:59:49.259572Z",
//            "poster": "https://image.tmdb.org/t/p/w1280/f4ANVEuEaGy2oP5M0Y2P1dwxUNn.jpg",
//            "overview": "William has failed to kill himself so many times that he outsources his suicide to aging assassin Leslie. But with the contract signed and death assured within a week (or his money back), William suddenly discovers reasons to live... However Leslie is under pressure from his boss to make sure the contract is completed."
//        }]
//        """
//
//
//        let decoder: JSONDecoder = JSONDecoder()
//        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
//        let data = jsonString.data(using: .utf8)!
//        let stubMovies: [Movie] = try! decoder.decode([Movie].self, from: data)
//
//        // Start the test with the mocked server
//
//        let uid: String = "books_test"
//        let limit: Int = 10
//
//        let expectation = XCTestExpectation(description: "Get Movies documents")
//
//        self.client.getDocuments(UID: uid, limit: limit) { (result: Result<[Movie], Swift.Error>) in
//
//            switch result {
//            case .success(let movies):
//                XCTAssertEqual(stubMovies, movies)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to get Movies documents")
//            }
//
//        }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }
//
//    func testDeleteDocument() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        {"updateId":0}
//        """
//
//        let decoder: JSONDecoder = JSONDecoder()
//        let jsonData = jsonString.data(using: .utf8)!
//        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)
//
//
//        // Start the test with the mocked server
//
//        let uid = "books_test"
//        let identifier: String = "25684"
//
//        let expectation = XCTestExpectation(description: "Delete Movies document")
//
//        self.client.deleteDocument(UID: uid, identifier: identifier) { result in
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(stubUpdate, update)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to delete Movies document")
//            }
//
//        }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }
//
//    func testDeleteAllDocuments() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        {"updateId":0}
//        """
//
//        let decoder: JSONDecoder = JSONDecoder()
//        let jsonData = jsonString.data(using: .utf8)!
//        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)
//
//        // Start the test with the mocked server
//
//        let uid = "books_test"
//        let expectation = XCTestExpectation(description: "Delete all Movies documents")
//
//        self.client.deleteAllDocuments(UID: uid) { result in
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(stubUpdate, update)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to delete all Movies documents")
//            }
//
//        }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }
//
//    func testDeleteBatchDocuments() {
//
//        //Prepare the mock server
//
//        let jsonString = """
//        {"updateId":0}
//        """
//
//        let decoder: JSONDecoder = JSONDecoder()
//        let jsonData = jsonString.data(using: .utf8)!
//        let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)
//
//        // Start the test with the mocked server
//
//        let uid = "books_test"
//        let documentsUID: [Int] = [23488, 153738, 437035, 363869]
//        let expectation = XCTestExpectation(description: "Delete all Movies documents")
//
//      self.client.deleteBatchDocuments(UID: uid, documentsUID: documentsUID) { result in
//
//            switch result {
//            case .success(let update):
//                XCTAssertEqual(stubUpdate, update)
//                expectation.fulfill()
//            case .failure:
//                XCTFail("Failed to delete all Movies documents")
//            }
//
//      }
//
//        self.wait(for: [expectation], timeout: 1.0)
//
//    }

    private func convertToDictionary(_ string: String) -> [String: Any] {
        if let data: Data = string.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        fatalError()
    }

    private func convertToArrayDictionary(_ string: String) -> [[String: Any]] {
        if let data: Data = string.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as! [[String: Any]]
            } catch {
                fatalError(error.localizedDescription)
            }
        }
        fatalError()
    }

    static var allTests = [
        ("testAddDocuments", testAddDocuments),
//        ("testUpdateDocuments", testUpdateDocuments),
//        ("testGetDocument", testGetDocument),
//        ("testGetDocuments", testGetDocuments),
//        ("testDeleteDocument", testDeleteDocument),
//        ("testDeleteAllDocuments", testDeleteAllDocuments),
//        ("testDeleteBatchDocuments", testDeleteBatchDocuments)
    ]

}
