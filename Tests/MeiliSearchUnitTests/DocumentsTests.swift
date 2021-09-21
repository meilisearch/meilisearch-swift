@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_cast
// swiftlint:disable force_try
// swiftlint:disable line_length
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
  private var index: Indexes!
  private var uid: String = "movies_test"

  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = self.client.index(self.uid)
  }

  func testAddDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server
    let movie = Movie(
      id: 287947,
      title: "Shazam",
      overview: "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
      releaseDate: Date(timeIntervalSince1970: TimeInterval(1553299200)))

    let expectation = XCTestExpectation(description: "Add or replace Movies document")

    self.index.addDocuments(
      documents: [movie],
      primaryKey: "id"
    ) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testAddDataDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server

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

    self.index.addDocuments(
      documents: documents,
      primaryKey: primaryKey
    ) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or replace Movies document")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testUpdateDataDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    // Start the test with the mocked server
    session.pushData(jsonString, code: 202)

    let documentJsonString = """
      [{
        "id": 287947,
        "title": "Shazam ⚡️"
      }]
      """

    let primaryKey: String = "movieskud"

    let JsonDocuments: Data = documentJsonString.data(using: .utf8)!

    let expectation = XCTestExpectation(description: "Add or update Movies document")

    self.index.updateDocuments(
      documents: JsonDocuments,
      primaryKey: primaryKey) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or update Movies document")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)
  }

  func testUpdateDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server

    let movie = Movie(
      id: 287947,
      title: "Shazam",
      overview: "A boy is given the ability to become an adult superhero in times of need with a single magic word.",
      releaseDate: Date(timeIntervalSince1970: TimeInterval(1553299200)))

    let expectation = XCTestExpectation(description: "add or update Movies document")

    self.index.updateDocuments(
      documents: [movie],
      primaryKey: "id"
    ) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to add or update Movies document")
      }
    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetDocument() {

    // Prepare the mock server

    let jsonString = """
      {
        "id": 25684,
        "title": "American Ninja 5",
        "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
        "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja.",
        "release_date": "2020-04-04T19:59:49.259572Z"
      }
      """

    session.pushData(jsonString, code: 200)

    let decoder: JSONDecoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
    let data = jsonString.data(using: .utf8)!
    let stubMovie: Movie = try! decoder.decode(Movie.self, from: data)

    // Start the test with the mocked server
    let identifier: String = "25684"

    let expectation = XCTestExpectation(description: "Get Movies document")

    self.index.getDocument(identifier: identifier) { (result: Result<Movie, Swift.Error>) in

      switch result {
      case .success(let movie):
        XCTAssertEqual(stubMovie, movie)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies document")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testGetDocuments() {

    // Prepare the mock server

    let jsonString = """
      [{
        "id": 25684,
        "release_date": "2020-04-04T19:59:49.259572Z",
        "poster": "https://image.tmdb.org/t/p/w1280/iuAQVI4mvjI83wnirpD8GVNRVuY.jpg",
        "title": "American Ninja 5",
        "overview": "When a scientists daughter is kidnapped, American Ninja, attempts to find her, but this time he teams up with a youngster he has trained in the ways of the ninja."
      },{
        "id": 468219,
        "title": "Dead in a Week (Or Your Money Back)",
        "release_date": "2020-04-04T19:59:49.259572Z",
        "poster": "https://image.tmdb.org/t/p/w1280/f4ANVEuEaGy2oP5M0Y2P1dwxUNn.jpg",
        "overview": "William has failed to kill himself so many times that he outsources his suicide to aging assassin Leslie. But with the contract signed and death assured within a week (or his money back), William suddenly discovers reasons to live... However Leslie is under pressure from his boss to make sure the contract is completed."
      }]
      """

    // Start the test with the mocked server
    session.pushData(jsonString, code: 200)

    let decoder: JSONDecoder = JSONDecoder()
    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
    let data = jsonString.data(using: .utf8)!
    let stubMovies: [Movie] = try! decoder.decode([Movie].self, from: data)

    let expectation = XCTestExpectation(description: "Get Movies documents")

    self.index.getDocuments { (result: Result<[Movie], Swift.Error>) in
      switch result {
      case .success(let movies):
        XCTAssertEqual(stubMovies, movies)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to get Movies documents")
      }
    }
    self.wait(for: [expectation], timeout: 5.0)
  }

  func testDeleteDocument() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server

    let identifier: String = "25684"

    let expectation = XCTestExpectation(description: "Delete Movies document")

    self.index.deleteDocument(identifier: identifier) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete Movies document")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testDeleteAllDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server

    let expectation = XCTestExpectation(description: "Delete all Movies documents")

    self.index.deleteAllDocuments { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete all Movies documents")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

  func testDeleteBatchDocuments() {

    // Prepare the mock server

    let jsonString = """
      {"updateId":0}
      """

    let decoder: JSONDecoder = JSONDecoder()
    let jsonData = jsonString.data(using: .utf8)!
    let stubUpdate: Update = try! decoder.decode(Update.self, from: jsonData)

    session.pushData(jsonString, code: 202)

    // Start the test with the mocked server
    let documentsIdentifiers: [Int] = [23488, 153738, 437035, 363869]
    let expectation = XCTestExpectation(description: "Delete all Movies documents")

    self.index.deleteBatchDocuments(documentsIdentifiers) { result in

      switch result {
      case .success(let update):
        XCTAssertEqual(stubUpdate, update)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to delete all Movies documents")
      }

    }

    self.wait(for: [expectation], timeout: 5.0)

  }

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
    ("testAddDataDocuments", testAddDataDocuments),
    ("testUpdateDocuments", testUpdateDocuments),
    ("testGetDocument", testGetDocument),
    ("testGetDocuments", testGetDocuments),
    ("testDeleteDocument", testDeleteDocument),
    ("testDeleteAllDocuments", testDeleteAllDocuments),
    ("testDeleteBatchDocuments", testDeleteBatchDocuments)
  ]

}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_cast
// swiftlint:enable force_try
// swiftlint:enable line_length
