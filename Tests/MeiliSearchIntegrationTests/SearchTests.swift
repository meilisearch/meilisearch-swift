@testable import MeiliSearch
import XCTest
import Foundation

// swiftlint:disable force_unwrapping
// swiftlint:disable force_try
private struct Book: Codable, Equatable {
  let id: Int
  let title: String
  let comment: String?
  let genres: [String]?
  let formatted: FormattedBook?
  let matchesInfo: MatchesInfoBook?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case comment
    case genres
    case formatted = "_formatted"
    case matchesInfo = "_matchesInfo"
  }

  init(id: Int, title: String, comment: String? = nil, genres: [String] = [], formatted: FormattedBook? = nil, matchesInfo: MatchesInfoBook? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
    self.genres = genres
    self.formatted = formatted
    self.matchesInfo = matchesInfo
  }
}

private struct FormattedBook: Codable, Equatable {
  let id: String
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = String(id)
    self.title = title
    self.comment = comment
  }
}

private struct MatchesInfoBook: Codable, Equatable {
  let comment: [Info]?
  let title: [Info]?
}

private struct Info: Codable, Equatable {
  let start: Int
  let length: Int
}

private let books: [Book] = [
  Book(id: 123, title: "Pride and Prejudice", comment: "A great book", genres: ["Classic Regency nove"]),
  Book(id: 456, title: "Le Petit Prince", comment: "A french book", genres: ["Novel"]),
  Book(id: 2, title: "Le Rouge et le Noir", comment: "Another french book", genres: ["Bildungsroman"]),
  Book(id: 1, title: "Alice In Wonderland", comment: "A weird book", genres: ["Fantasy"]),
  Book(id: 1344, title: "The Hobbit", comment: "An awesome book", genres: ["High fantasy"]),
  Book(id: 4, title: "Harry Potter and the Half-Blood Prince", comment: "The best book", genres: ["Fantasy"]),
  Book(id: 42, title: "The Hitchhiker's Guide to the Galaxy", genres: ["Novel"]),
  Book(id: 1844, title: "A Moreninha", comment: "A Book from Joaquim Manuel de Macedo", genres: ["Novel"])
]

class SearchTests: XCTestCase {
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
    self.wait(for: [addDocExpectation], timeout: 20.0)
  }

  // MARK: Basic search

  func testBasicSearch() {
    let expectation = XCTestExpectation(description: "Search for Books with query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        XCTAssertTrue(response.query == query)
        XCTAssertTrue(response.limit == 20)
        XCTAssertTrue(response.hits.count == 1)
        if response.hits.count > 0 {
          XCTAssertEqual("A Moreninha", response.hits[0].title)
          XCTAssertNil(response.hits[0].formatted)
        } else {
          XCTFail("Failed to find hits in the response")
        }
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testBasicSearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testBasicSearchWithNoQuery() {
    let expectation = XCTestExpectation(description: "Search for Books without query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>

    self.index.search(SearchParameters(query: nil)) { (result: MeiliResult) in
      switch result {
      case .success(let response):
        XCTAssertEqual("", response.query)
        XCTAssertEqual(20, response.limit)
        XCTAssertEqual(books.count, response.hits.count)
        XCTAssertEqual("Alice In Wonderland", response.hits[0].title)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testBasicSearchWithNoQuery")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Phrase search

  func testPhraseSearch() {
    let expectation = XCTestExpectation(description: "Search for Books using phrase search")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let query = "A \"great book\""

    self.index.search(SearchParameters(query: query)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == 20)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertEqual("Pride and Prejudice", documents.hits[0].title)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testPhraseSearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Limit

  func testSearchLimit() {
    let expectation = XCTestExpectation(description: "Search for Books using limit")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertEqual("A Moreninha", documents.hits[0].title)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimit")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchZeroLimit() {
    let expectation = XCTestExpectation(description: "Search for Books using zero limit")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 0
    let query = "A Moreninha"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.isEmpty)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchZeroLimit")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchLimitBiggerThanNumberOfBooks() {
    let expectation = XCTestExpectation(description: "Search for Books using limit bigger than the number of books stored")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "A"

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == limit)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimitBiggerThanNumberOfBooks")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchLimitEmptySearch() {
    let expectation = XCTestExpectation(description: "Search for Books using limit but nothing in the query")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = ""

    self.index.search(SearchParameters(query: query, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 5)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchLimitEmptySearch")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Offset

  func testSearchOffset() {
    let expectation = XCTestExpectation(description: "Search for Books using offset")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 2
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 2)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffset")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchOffsetZero() {
    let expectation = XCTestExpectation(description: "Search for Books using zero offset")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 0
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 2)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffsetZero")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchOffsetLastPage() {
    let expectation = XCTestExpectation(description: "Search for Books using a offset at the last page")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let offset = 6
    let query = "A"

    self.index.search(SearchParameters(query: query, offset: offset, limit: limit)) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.offset == offset)
        XCTAssertTrue(documents.hits.count == 1)
        XCTAssertNil(documents.hits[0].formatted)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchOffsetLastPage")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Attributes to crop

  func testSearchAttributesToCrop() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to crop")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let query = "de Macedo"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book: Book = documents.hits[0]
        XCTAssertEqual("Manuel de Macedo", book.formatted!.comment!)
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail("Failed to search with testSearchAttributesToCrop")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Crop length

  func testSearchCropLength() {
    let expectation = XCTestExpectation(description: "Search for Books using default crop length")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 2
    let query = "book"
    let attributesToCrop = ["comment"]
    let cropLength = 5
    let searchParameters = SearchParameters(query: query, limit: limit, attributesToCrop: attributesToCrop, cropLength: cropLength)

    self.index.search(searchParameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 2)

        let moreninhaBook: Book = documents.hits.first(where: { book in book.id == 1844 })!
        XCTAssertEqual("A Book from", moreninhaBook.formatted!.comment!)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchCropLength")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Matches tests

  func testSearchMatches() {
    let expectation = XCTestExpectation(description: "Search for Books using matches")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Moreninha"
    let parameters = SearchParameters(query: query, limit: limit, matches: true)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)

        let matchesInfo = book.matchesInfo!
        if let titleMatches = matchesInfo.title {
          let firstMatch = titleMatches[0]
          XCTAssertEqual(2, firstMatch.start)
          XCTAssertEqual(9, firstMatch.length)
        } else {
          XCTFail("Comment is not as expected in _matchesInfo")
        }
        expectation.fulfill()
      case .failure(let error):
        print(error)
        XCTFail("Failed to search with testSearchMatches")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Attributes to highlight

  func testSearchAttributesToHighlight() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to highlight")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToHighlight = ["comment"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToHighlight: attributesToHighlight)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertTrue(book.formatted!.comment!.contains("<em>Joaquim</em> <em>Manuel</em> <em>de</em> <em>Macedo</em>"))
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchAttributesToHighlight")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Attributes to retrieve

  func testSearchAttributesToRetrieve() {
    let expectation = XCTestExpectation(description: "Search for Books using attributes to retrieve")

    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "Joaquim Manuel de Macedo"
    let attributesToRetrieve = ["id", "title"]
    let parameters = SearchParameters(query: query, limit: limit, attributesToRetrieve: attributesToRetrieve)

    self.index.search(parameters) { (result: MeiliResult) in
      switch result {
      case .success(let documents):
        XCTAssertTrue(documents.query == query)
        XCTAssertTrue(documents.limit == limit)
        XCTAssertTrue(documents.hits.count == 1)
        let book = documents.hits[0]
        XCTAssertEqual(1844, book.id)
        XCTAssertEqual("A Moreninha", book.title)
        XCTAssertNil(book.comment)
        expectation.fulfill()
      case .failure(let error):
        dump(error)
        XCTFail("Failed to search with testSearchAttributesToRetrieve")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Filters

  private func configureFilters(_ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    let filterableAttributes = ["genres", "author", "id"]
    let settings = Setting(
      rankingRules: ["words", "typo", "proximity", "attribute", "sort", "exactness"],
      searchableAttributes: ["*"],
      displayedAttributes: ["*"],
      stopWords: ["the", "a"],
      synonyms: [:],
      distinctAttribute: nil,
      filterableAttributes: filterableAttributes,
      sortableAttributes: ["id"]
      )

    self.index.updateSettings(settings) { result in
      switch result {
      case .success(let task):
        self.client.waitForTask(task: task) { result in
          switch result {
          case .success:
            completion(.success(()))
          case .failure(let error):
            dump(error)
            completion(.failure(error))
          }
        }
      case .failure(let error):
        dump(error)
        completion(.failure(error))
      }
    }
  }

  func testSearchFilters() {
    let expectation = XCTestExpectation(description: "Search for Books using filter")
    typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
    let limit = 5
    let query = "french book"
    let filter = "id = 456"
    let parameters = SearchParameters(query: query, limit: limit, filter: filter)

    configureFilters { result in
      switch result {
      case .success:
        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            XCTAssertTrue(documents.limit == limit)
            XCTAssertTrue(documents.hits.count == 1)
            let book = documents.hits[0]
            XCTAssertEqual(456, book.id)
            XCTAssertEqual("Le Petit Prince", book.title)
            XCTAssertEqual("A french book", book.comment)
            expectation.fulfill()
          case .failure(let error):
            print(error)
            XCTFail("Failed to search with testSearchFilters")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchSorting() {
    let expectation = XCTestExpectation(description: "Search for Books using sort on id")
    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
        let query = ""
        let sort = ["id:asc"]
        let parameters = SearchParameters(query: query, sort: sort)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            let book = documents.hits[0]
            XCTAssertEqual(1, book.id)
            XCTAssertEqual("Alice In Wonderland", book.title)
            expectation.fulfill()
          case .failure(let error):
            print(error)
            XCTFail("Failed to search with sorting parameter")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchFiltersNotMatching() {
    let expectation = XCTestExpectation(description: "Search for Books using filters but the query and filters are not matching")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
        let limit = 5
        let query = "Joaquim Manuel de Macedo"
        let filter = "id = 456"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            XCTAssertTrue(documents.limit == limit)
            XCTAssertTrue(documents.hits.isEmpty)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFiltersNotMatching")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        print(error)
        XCTFail("Failed to search with testSearchFilters")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 20.0)
  }

  func testSearchFacetsFilters() {
    let expectation = XCTestExpectation(description: "Search for Books using facets filters")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
        let limit = 5
        let query = "A"
        let filter = "genres = Novel"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            XCTAssertTrue(documents.limit == limit)
            XCTAssertTrue(documents.hits.count == 2)
            let moreninhaBook: Book = documents.hits.first { book in book.id == 1844 }!
            XCTAssertEqual("A Moreninha", moreninhaBook.title)
            let petitBook: Book = documents.hits.first { book in book.id == 456 }!
            XCTAssertEqual("Le Petit Prince", petitBook.title)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetsFilters")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 2.0)
  }

  func testSearchFilterWithEmptySpace() {
    let expectation = XCTestExpectation(description: "Search for Books using filters with a space in the value")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Error>

        let query = ""
        let limit = 5
        let filter = "genres = 'High fantasy'"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertEqual(documents.query, query)
            XCTAssertEqual(documents.limit, limit)
            XCTAssertEqual(documents.hits.count, 1)
            guard let book: Book = documents.hits.first(where: { book in book.id == 1344 }) else {
              XCTFail("Failed to search with testSearchFilterWithEmptySpace")
              expectation.fulfill()
              return
            }
            XCTAssertEqual("The Hobbit", book.title)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFilterWithEmptySpace")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 20.0)
  }

  // MARK: Facets distribution

  func testSearchFacetsDistribution() {
    let expectation = XCTestExpectation(description: "Search for Books using facets distribution")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
        let limit = 5
        let query = "A"
        let facetsDistribution = ["genres"]
        let parameters = SearchParameters(query: query, limit: limit, facetsDistribution: facetsDistribution)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            XCTAssertTrue(documents.limit == limit)
            XCTAssertTrue(documents.hits.count == limit)

            let facetsDistribution = documents.facetsDistribution!
            let expected: [String: [String: Int]] = [
              "genres": [
                "Classic Regency nove": 1,
                "High fantasy": 1,
                "Fantasy": 2,
                "Novel": 2,
                "Bildungsroman": 1
              ]
            ]
            XCTAssertEqual(expected, facetsDistribution)
            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetsDistribution")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }

    self.wait(for: [expectation], timeout: 2.0)
  }

  func testSearchFacetsDistributionNullValue() {
    let expectation = XCTestExpectation(description: "Search for Books using facets distribution with 0 value")

    configureFilters { result in
      switch result {
      case .success:
        typealias MeiliResult = Result<SearchResult<Book>, Swift.Error>
        let limit = 5
        let query = "Petit Prince"
        let facetsDistribution = ["genres"]
        let filter = "genres = comedy"
        let parameters = SearchParameters(query: query, limit: limit, filter: filter, facetsDistribution: facetsDistribution)

        self.index.search(parameters) { (result: MeiliResult) in
          switch result {
          case .success(let documents):
            XCTAssertTrue(documents.query == query)
            XCTAssertTrue(documents.limit == limit)
            XCTAssertTrue(documents.hits.count == 0)

            let facetsDistribution = documents.facetsDistribution!
            XCTAssertEqual(["genres": [:]], facetsDistribution)

            expectation.fulfill()
          case .failure(let error):
            dump(error)
            XCTFail("Failed to search with testSearchFacetsDistribution")
            expectation.fulfill()
          }
        }
      case .failure(let error):
        dump(error)
        XCTFail("Could not update settings")
        expectation.fulfill()
      }
    }
    self.wait(for: [expectation], timeout: 2.0)
  }
}
// swiftlint:enable force_unwrapping
// swiftlint:enable force_try
