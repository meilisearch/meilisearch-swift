import Foundation

struct Search {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
        self.request = request
    }

    func search<T>(
        _ UID: String,
        _ searchParameters: SearchParameters,
        _ completion: @escaping (Result<SearchResult<T>, Swift.Error>) -> Void)
        where T: Codable, T: Equatable {

        let api: String = queryURL(
            api: "/indexes/\(UID)/search",
            searchParameters.dictionary())

        self.request.get(api: api) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

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

            let decoder: JSONDecoder
            if let customDecoder: JSONDecoder = customDecoder {
              decoder = customDecoder
            } else {
              decoder = Constants.customJSONDecoder
            }

            let value: T = try decoder.decode(T.self, from: data)
            completion(.success(value))
        } catch {
            completion(.failure(error))
        }
    }

}
