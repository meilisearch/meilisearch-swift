import Vapor
import MeiliSearch

func routes(_ app: Application) throws {

    let client = MeiliSearchClient(Config(hostURL: "http://localhost:7700"))

    app.get("index") { req -> EventLoopFuture<String> in

        /// Create a new void promise
        let promise = req.eventLoop.makePromise(of: String.self)

        /// Dispatch some work to happen on a background thread
        req.application.threadPool.submit { _ in

            guard let uid: String = req.query["uid"] else {
                promise.fail(Abort(.badRequest))
                return
            }

            client.getIndex(uid: uid) { result in

              switch result {
              case .success(let index):

                let encoder = JSONEncoder()
                let data = try! encoder.encode(index)
                let dataString = String(decoding: data, as: UTF8.self)

                promise.succeed(dataString)

              case .failure(let error):
                promise.fail(error)
              }

            }

        }

        /// Wait for the future to be completed,
        /// then transform the result to a simple String
        return promise.futureResult
    }

    app.get("search") { req -> EventLoopFuture<String> in

        /// Create a new void promise
        let promise = req.eventLoop.makePromise(of: String.self)

        /// Dispatch some work to happen on a background thread
        req.application.threadPool.submit { _ in

            guard let uid: String = req.query["uid"] else {
                promise.fail(Abort(.badRequest))
                return
            }

            client.getIndex(uid: uid) { result in

              switch result {
              case .success(let index):

                let encoder = JSONEncoder()
                let data = try! encoder.encode(index)
                let dataString = String(decoding: data, as: UTF8.self)

                promise.succeed(dataString)

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
