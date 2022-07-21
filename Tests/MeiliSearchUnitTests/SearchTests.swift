@testable import MeiliSearch
import XCTest

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
private struct Movie: Codable, Equatable {
  let id: Int
  let title: String
  let poster: String
  let overview: String
  let releaseDate: Date

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case poster
    case overview
    case releaseDate = "release_date"
  }
}

class SearchTests: XCTestCase {
  private var client: MeiliSearch!
  private var index: Indexes!
  private let session = MockURLSession()

  override func setUp() {
    super.setUp()
    client = try! MeiliSearch(host: "http://localhost:7700", apiKey: "masterKey", session: session)
    index = client.index("movies_test")
  }

  func testSearchForBotmanMovie() {
    let jsonString = """
      {
        "hits": [
          {
            "id": 29751,
            "title": "Batman Unmasked: The Psychology of the Dark Knight",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 471474,
            "title": "Batman: Gotham by Gaslight",
            "poster": "https://image.tmdb.org/t/p/w1280/7souLi5zqQCnpZVghaXv0Wowi0y.jpg",
            "overview": "ve Victorian Age Gotham City, Batman begins his war on crime",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "estimatedTotalHits": 2,
        "query": "botman"
      }
      """

    // Prepare the mock server
    let data = jsonString.data(using: .utf8)!
    let stubSearchResult: SearchResult<Movie> = try! Constants.customJSONDecoder.decode(SearchResult<Movie>.self, from: data)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters.query("botman")
    let expectation = XCTestExpectation(description: "Searching for botman")
    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let searchResult):
        XCTAssertEqual(stubSearchResult, searchResult)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search for botman")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testSearchForBotmanMovieFacets() {
    let jsonString = """
      {
        "hits": [
          {
            "id": 29751,
            "title": "Batman Unmasked: The Psychology of the Dark Knight",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 471474,
            "title": "Batman: Gotham by Gaslight",
            "poster": "https://image.tmdb.org/t/p/w1280/7souLi5zqQCnpZVghaXv0Wowi0y.jpg",
            "overview": "ve Victorian Age Gotham City, Batman begins his war on crime",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "estimatedTotalHits": 2,
        "query": "botman"
      }
      """

    // Prepare the mock server
    let data = jsonString.data(using: .utf8)!
    let stubSearchResult: SearchResult<Movie> = try! Constants.customJSONDecoder.decode(SearchResult<Movie>.self, from: data)
    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters(
      query: "botman",
      filter: "genre = romance OR genre = Science Fiction",
      sort: ["id:asc"]
    )

    let expectation = XCTestExpectation(description: "Searching for botman")
    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let searchResult):
        XCTAssertEqual(stubSearchResult, searchResult)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search for botman")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: TESTS_TIME_OUT)
  }

  func testShouldFilterValuesWithSpaces() {
    let jsonString = """
      {
        "hits": [
          {
            "id": 123,
            "title": "Pride and Prejudice",
            "comment": "A great book",
            "genre": "romance",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 456,
            "title": "Le Petit Prince",
            "comment": "A french book about a prince that walks on little cute planets",
            "genre": "adventure",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 2,
            "title": "Le Rouge et le Noir",
            "comment": "Another french book",
            "genre": "romance",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 1,
            "title": "Alice In Wonderland",
            "comment": "A weird book",
            "genre": "adventure",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 1344,
            "title": "The Hobbit",
            "comment": "An awesome book",
            "genre": "sci fi",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 4,
            "title": "Harry Potter and the Half-Blood Prince",
            "comment": "The best book",
            "genre": "fantasy",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          },
          {
            "id": 42,
            "title": "The Hitchhiker's Guide to the Galaxy",
            "genre": "fantasy",
            "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
            "overview": "Delve into the world of Batman and the vigilante justice tha",
            "release_date": "2020-04-04T19:59:49.259572Z"
          }
        ],
        "offset": 0,
        "limit": 20,
        "processingTimeMs": 2,
        "estimatedTotalHits": 1,
        "query": "h",
        "genre": "sci fi"
      }
      """

    // Prepare the mock server
    guard let data = jsonString.data(using: .utf8), let stubSearchResult = try? Constants.customJSONDecoder.decode(SearchResult<Movie>.self, from: data) else {
      XCTFail("Failed to encode JSON data")
      return
    }

    session.pushData(jsonString)

    // Start the test with the mocked server
    let searchParameters = SearchParameters(
      query: "h",
      filter: "genre = 'sci fi'",
      sort: ["id:asc"]
    )

    let expectation = XCTestExpectation(description: "Searching for the hobbit")
    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    index .search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let searchResult):
        XCTAssertEqual(stubSearchResult, searchResult)
        XCTAssertEqual(searchResult.estimatedTotalHits, 1)
        expectation.fulfill()
      case .failure:
        XCTFail("Failed to search for botman")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 20.0)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
