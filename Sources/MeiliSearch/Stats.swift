import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct Stats {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func stats(
    _ uid: String,
    query: StatsQuery? = nil,
    _ completion: @escaping (Result<Stat, Swift.Error>) -> Void) {
    let param = query?.toQuery()
    self.request.get(api: "/indexes/\(uid)/stats", param: param) { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let stat: Stat = try Constants.customJSONDecoder.decode(Stat.self, from: data)
          completion(.success(stat))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func allStats(
    query: StatsQuery? = nil,
    _ completion: @escaping (Result<AllStats, Swift.Error>) -> Void) {
    let param = query?.toQuery()
    self.request.get(api: "/stats", param: param) { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let allStats: AllStats = try Constants.customJSONDecoder.decode(AllStats.self, from: data)
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
