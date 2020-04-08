import Foundation

struct Stats {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
      self.request = request
    }

    func stat(
      _ UID: String,
      _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/stats") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
                    let stat: Stat = try decoder.decode(Stat.self, from: data)
                    completion(.success(stat))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func allStats(_ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {

        self.request.get(api: "/stats") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
                    let allStats: AllStats = try decoder.decode(AllStats.self, from: data)
                    completion(.success(allStats))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}
