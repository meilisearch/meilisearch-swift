import Foundation

struct Keys {
  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  func get(key: String, _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    self.request.get(api: "/keys/\(key)") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let decoder = JSONDecoder()
          let key: Key = try decoder.decode(Key.self, from: data)
          completion(.success(key))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getAll(_ completion: @escaping (Result<Results<Key>, Swift.Error>) -> Void) {
    self.request.get(api: "/keys") { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let keys: Results<Key> = try Constants.customJSONDecoder.decode(Results<Key>.self, from: data)
          completion(.success(keys))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func create(
    description: String,
    actions: [String],
    indexes: [String],
    expiresAt: String?,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let payload = CreateKeyPayload(
      description: description,
      actions: actions,
      indexes: indexes,
      expiresAt: expiresAt
    )
    let data: Data
    do {
      let encoder = JSONEncoder()
      data = try encoder.encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }
    self.request.post(api: "/keys", data) { result in
      switch result {
      case .success(let data):
      do {
        let key: Key = try Constants.customJSONDecoder.decode(
          Key.self,
          from: data)
          completion(.success(key))
      } catch {
        completion(.failure(error))
      }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func update(
    key: String,
    description: String,
    actions: [String],
    indexes: [String],
    expiresAt: String?,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let payload = CreateKeyPayload(
      description: description,
      actions: actions,
      indexes: indexes,
      expiresAt: expiresAt
    )
    let data: Data
    do {
      let encoder = JSONEncoder()
      data = try encoder.encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }
    self.request.patch(api: "/keys/\(key)", data) { result in
      switch result {
      case .success(let data):
      do {
        let key: Key = try Constants.customJSONDecoder.decode(
          Key.self,
          from: data)
          completion(.success(key))
      } catch {
        completion(.failure(error))
      }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func delete(
    key: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.request.delete(api: "/keys/\(key)") { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  struct CreateKeyPayload: Codable {
      public let description: String
      public let actions: [String]
      public let indexes: [String]
      public let expiresAt: String?

      func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(description, forKey: .description)
        try container.encode(actions, forKey: .actions)
        try container.encode(indexes, forKey: .indexes)
        try container.encode(expiresAt, forKey: .expiresAt)
      }
  }
}
