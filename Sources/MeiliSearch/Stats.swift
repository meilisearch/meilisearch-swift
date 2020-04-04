import Foundation

final class Stats {

    let request: Request
    
    init (config: Config) {
        request = Request(config: config)
    }

    func stat(uid: String, _ completion: @escaping (Result<Stat, Error>) -> Void) {

        self.request.get(api: "/indexes/\(uid)/stats") { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    fatalError()
                }

                do {
                    let decoder = JSONDecoder()
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

    func allStats(_ completion: @escaping (Result<AllStats, Error>) -> Void) {

        self.request.get(api: "/stats") { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    fatalError()
                }

                do {
                    let decoder = JSONDecoder()
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