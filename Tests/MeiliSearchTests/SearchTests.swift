@testable import MeiliSearch
import XCTest

class SearchTests: XCTestCase {

    private var client: MeiliSearchClient!
    private let session = MockURLSession()

    override func setUp() {
        super.setUp()
        client = MeiliSearchClient(Config(hostURL: "http://localhost:7700", session: session))
    }

    func testSearchForBotmanMovie() {

        //Prepare the mock server

        let jsonString = """
        {
            "hits": [
                {
                    "id": "29751",
                    "title": "Batman Unmasked: The Psychology of the Dark Knight",
                    "poster": "https://image.tmdb.org/t/p/w1280/jjHu128XLARc2k4cJrblAvZe0HE.jpg",
                    "overview": "Delve into the world of Batman and the vigilante justice tha",
                    "release_date": "2008-07-15"
                },
                {
                    "id": "471474",
                    "title": "Batman: Gotham by Gaslight",
                    "poster": "https://image.tmdb.org/t/p/w1280/7souLi5zqQCnpZVghaXv0Wowi0y.jpg",
                    "overview": "ve Victorian Age Gotham City, Batman begins his war on crime",
                    "release_date": "2018-01-12"
                }
            ],
            "offset": 0,
            "limit": 20,
            "processingTimeMs": 2,
            "query": "botman"
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let json: Any = try! JSONSerialization.jsonObject(with: jsonData, options: [])
        let stubSearchResult: SearchResult = SearchResult(json: json)

        session.pushData(jsonString)

        // Start the test with the mocked server

        let uid: String = "Movies"

        let searchParameters = SearchParameters.query("botman")

        let expectation = XCTestExpectation(description: "Searching for botman")

        self.client.search(uid: uid, searchParameters: searchParameters) { result in
            switch result {
            case .success(let searchResult):

                XCTAssertEqual(stubSearchResult.hits.count, searchResult.hits.count)
                XCTAssertEqual(stubSearchResult.offset, searchResult.offset)
                XCTAssertEqual(stubSearchResult.limit, searchResult.limit)
                XCTAssertEqual(stubSearchResult.processingTimeMs, searchResult.processingTimeMs)
                XCTAssertEqual(stubSearchResult.query, searchResult.query)

                expectation.fulfill()
            case .failure:
                XCTFail("Failed to search for botman")
            }
        }

        self.wait(for: [expectation], timeout: 1.0)

    }

    static var allTests = [
        ("testSearchForBotmanMovie", testSearchForBotmanMovie)
    ]

}