import Foundation

struct Search {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func search<T>(
    _ uid: String,
    _ searchParameters: SearchParameters,
    _ completion: @escaping (Result<SearchResult<T>, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    let data: Data
    do {
      data = try JSONEncoder().encode(searchParameters)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.post(api: "/indexes/\(uid)/search", data) { result in
      switch result {
      case .success(let data):

        Search.decodeJSON(data, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  private static func decodeJSON<T: Codable>(
    _ data: Data,
    _ customDecoder: JSONDecoder? = nil,
    completion: (Result<T, Swift.Error>) -> Void) {
    do {
      let decoder: JSONDecoder = customDecoder ?? Constants.customJSONDecoder
      let value: T = try decoder.decode(T.self, from: data)
      completion(.success(value))
    } catch {
      completion(.failure(error))
    }
  }
}
