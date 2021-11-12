import Vapor
import MeiliSearch

private struct Movie: Codable, Equatable {
  // swiftlint:disable identifier_name
  let id: Int
  // swiftlint:enable identifier_name
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
  }
}

func routes(_ app: Application) throws {
  guard let client = try? MeiliSearch(host: "127.0.0.1:7700", apiKey: "masterKey") else {
    throw NSError(domain: "Failed to initialize MeiliSearch", code: 123)
  }

  // 127.0.0.1:8080/index?uid=books_test
  app.get("index") { req -> EventLoopFuture<String> in
    /// Create a new void promise
    let promise = req.eventLoop.makePromise(of: String.self)

    /// Dispatch some work to happen on a background thread
    req.application.threadPool.submit { _ in
      guard let uid: String = req.query["uid"] else {
        promise.fail(Abort(.badRequest))
        return
      }

      client.getIndex(uid) { result in
        switch result {
        case .success(let index):

          let encoder = JSONEncoder()
          if let data: Data = try? encoder.encode(index) {
            let dataString = String(decoding: data, as: UTF8.self)
            promise.succeed(dataString)
          }

        case .failure(let error):
          promise.fail(error)
        }
      }
    }

    /// Wait for the future to be completed,
    /// then transform the result to a simple String
    return promise.futureResult
  }

  // 127.0.0.1:8080/search?query=botman
  app.get("search") { req -> EventLoopFuture<String> in
    /// Create a new void promise
    let promise = req.eventLoop.makePromise(of: String.self)

    /// Dispatch some work to happen on a background thread
    req.application.threadPool.submit { _ in
      guard let query: String = req.query["query"] else {
        promise.fail(Abort(.badRequest))
        return
      }

      let searchParameters = SearchParameters.query(query)

      client.index("movies").search(searchParameters) { (result: Result<SearchResult<Movie>, Swift.Error>) in
        switch result {
        case .success(let searchResult):
          if let jsonData = try? JSONSerialization.data(withJSONObject: searchResult.hits, options: []) {
            let dataString = String(decoding: jsonData, as: UTF8.self)
            promise.succeed(dataString)
          }
        case .failure(let error):
          promise.fail(error)
        }
      }
    }

    /// Wait for the future to be completed,
    /// then transform the result to a simple String
    return promise.futureResult
  }
}
