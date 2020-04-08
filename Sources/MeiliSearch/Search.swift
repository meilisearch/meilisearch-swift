import Foundation

struct Search {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
      self.request = request
    }

    func search(
      _ UID: String,
      _ searchParameters: SearchParameters,
      _ completion: @escaping (Result<SearchResult, Swift.Error>) -> Void) {

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
