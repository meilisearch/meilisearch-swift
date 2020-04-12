import Foundation

struct System {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
        self.request = request
    }

    func health(_ completion: @escaping (Result<(), Swift.Error>) -> Void) {

        self.request.get(api: "/health") { result in

            switch result {
            case .success:
                completion(.success(()))

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

  func updateHealth(
      _ health: Bool,
      _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

      let payload = CreateHealthPayload(health: health)
      let data: Data

      do {
          data = try JSONEncoder().encode(payload)
      } catch {
          completion(.failure(MeiliSearch.Error.invalidJSON))
          return
      }

      self.request.put(api: "/health", body: data) { result in
          switch result {
          case .success:
              completion(.success(()))

          case .failure(let error):
              completion(.failure(error))
          }
      }

  }

    func version(_ completion: @escaping (Result<Version, Swift.Error>) -> Void) {

        self.request.get(api: "/version") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
                    let vesion: Version = try decoder.decode(Version.self, from: data)
                    completion(.success(vesion))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func systemInfo(_ completion: @escaping (Result<SystemInfo, Swift.Error>) -> Void) {

        self.request.get(api: "/sys-info") { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let systemInfo: SystemInfo = try decoder.decode(SystemInfo.self, from: data)
                    completion(.success(systemInfo))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func prettySystemInfo(_ completion: @escaping (Result<PrettySystemInfo, Swift.Error>) -> Void) {

        self.request.get(api: "/sys-info/pretty") { result in

            switch result {
            case .success(let data):

                guard let data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let prettySystemInfo: PrettySystemInfo =
                      try decoder.decode(PrettySystemInfo.self, from: data)
                    completion(.success(prettySystemInfo))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}

struct CreateHealthPayload: Codable {
    let health: Bool
}
