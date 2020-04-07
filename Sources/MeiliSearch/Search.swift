import Foundation

final class Search {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (config: Config) {
        request = Request(config: config)
    }

    func search(
      uid: String,
      searchParameters: SearchParameters,
      _ completion: @escaping (Result<SearchResult, Swift.Error>) -> Void) {

        let api: String = queryURL(
            api: "/indexes/\(uid)/search",
            searchParameters.dictionary())

        self.request.get(api: api) { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let json: Any = try JSONSerialization.jsonObject(
                        with: data,
                        options: [])
                    let result = SearchResult(json: json)
                    completion(.success(result))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}
