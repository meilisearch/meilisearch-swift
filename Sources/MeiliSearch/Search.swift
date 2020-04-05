import Foundation

final class Search {

    let request: Request

    init (config: Config) {
        request = Request(config: config)
    }

    func search(
      uid: String, 
      searchParameters: SearchParameters,
      _ completion: @escaping (Result<SearchResult, Error>) -> Void) {

        let api: String = queryURL(
            api: "/indexes/\(uid)/search", 
            searchParameters.dictionary())

        self.request.get(api: api) { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    fatalError()
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
