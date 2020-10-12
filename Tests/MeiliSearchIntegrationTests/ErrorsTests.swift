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

class ErrorsTests: XCTestCase {

    private var client: MeiliSearch!
    private let uid: String = "books_test"

    override func setUp() {
        super.setUp()

        if client == nil {
            client = try! MeiliSearch(
              Config.default(apiKey: "masterKey"))
        }

        pool(client)

        let expectation = XCTestExpectation(description: "Create index if it does not exist")

        self.client.deleteIndex(UID: uid) { _ in
            self.client.getOrCreateIndex(UID: self.uid) { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    print(error)
                }
                expectation.fulfill()
            }
        }

        self.wait(for: [expectation], timeout: 10.0)
    }

    func testGetDocumentThatDoesNotExistAndFail() {

        let getExpectation = XCTestExpectation(description: "Get one document and fail")
        self.client.getDocument(
            UID: self.uid,
            identifier: "123456"
        ) { (result: Result<Movie, Swift.Error>) in
            switch result {
            case .success:
                XCTFail("Document has been found while it should not have")
            case .failure(let error):
                print(error) // Outputs the following
                /*
                    MSError(data: Optional(MeiliSearch.MSErrorResponse(message: "Document with id 123456 not found", errorCode: "document_not_found", errorType: "invalid_request_error", errorLink: Optional("https://docs.meilisearch.com/errors#document_not_found"))), underlying: Error Domain=HttpStatus Code=404 "(null)")
                */
                XCTAssertEqual("document_not_found", error.errorCode) // How do I say that error is a MSError ?
                getExpectation.fulfill()
            }
        }
        self.wait(for: [getExpectation], timeout: 3.0)
    }

    func testCreateSameIndexTwiceAndFail() {
        // "index already exists" shoudl be used using error.errorCode
        let createExpectation = XCTestExpectation(description: "Create same index twice")

        self.client.createIndex(UID: self.uid) { result in
            switch result {
            case .success:
                XCTFail("Create Index should not have worked")
            case .failure(let error):
                print(error)
                // XCTAssertEqual("index_already_exists", error.)
                createExpectation.fulfill()
            }
        }

        self.wait(for: [createExpectation], timeout: 1.0)
    }



    static var allTests = [
        ("testCreateSameIndexTwiceAndFail", testCreateSameIndexTwiceAndFail),
    ]

}
