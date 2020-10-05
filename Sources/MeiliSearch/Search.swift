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
            
            let searchParamBody: Data
            do {
               searchParamBody = try JSONEncoder().encode(searchParameters)
           } catch {
               completion(.failure(MeiliSearch.Error.invalidJSON))
               return
           }
            let api: String = "/indexes/\(UID)/search"

            self.request.post(api: api, searchParamBody) { result in

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
