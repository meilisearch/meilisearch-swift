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

class UpdatesTests: XCTestCase {

    private var client: MeiliSearch!
    private let uid: String = "books_test"

    // MARK: Setup

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

        self.client.addDocuments(UID: self.uid, documents: documents, primaryKey: nil) { result in

            switch result {
            case .success(let update):

              func getUpdate() {

                self.client.getUpdate(UID: self.uid, update) { result in

                    switch result {
                    case .success(let update):

                        if update.status == "enqueued" {
                          getUpdate()
                          return
                        }

                        expectation.fulfill()
                    case .failure(let error):
                        print(error)
                        XCTFail()
                    }

                }

              }

              getUpdate()

            case .failure:
                XCTFail("Failed to update movie index")
            }
        }

        self.wait(for: [expectation], timeout: 10.0)

    }

    func testGetAllUpdatesStatus() {

        let expectation = XCTestExpectation(description: "Get update status for all transaction")

        let jsonEncoder = JSONEncoder()

        for i in 0...10 {
            let movie: Movie = Movie(id: i, title: "test\(i)", comment: "test movie\(i)")
            let documents: Data = try! jsonEncoder.encode([movie])
            self.client.addDocuments(UID: self.uid, documents: documents, primaryKey: nil) { _ in }
        }

        func getAllUpdates() {

          self.client.getAllUpdates(UID: self.uid) { result in

              switch result {
              case .success(let updates):

                  let enqueues = updates
                    .filter { (update: Update.Result) in update.status != "processed" }
                    .count

                  if enqueues > 0 {
                    getAllUpdates()
                    return
                  }

                  expectation.fulfill()
              case .failure(let error):
                  print(error)
                  XCTFail()
              }

          }

        }

        getAllUpdates()

        self.wait(for: [expectation], timeout: 10.0)

    }

}
