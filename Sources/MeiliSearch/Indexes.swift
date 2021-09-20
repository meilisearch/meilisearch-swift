import Foundation

public struct Indexes {

  // MARK: Properties

  let request: Request
  let config: Config
  // let uid: String?

  /// The index uid.
  public let uid: String

  /// The data when the index was created.
  public let createdAt: Date?

  /// The data when the index was last updated.
  public let updatedAt: Date?

  /// The primary key configured for the index.
  public let primaryKey: String?

  // MARK: Initializers

  init (
    _ config: Config,
    _ uid: String,
    primaryKey: String? = nil,
    _ createdAt: Date? = nil,
    _ updatedAt: Date? = nil
    ) {
    self.config = config
    self.request = Request(self.config)
    self.uid = uid
    self.primaryKey = primaryKey
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }

  enum CodingKeys: String, CodingKey {
    case uid = "uid"
    case primaryKey
    case createdAt
    case updatedAt
  }

  // MARK: Functions

  public func get(_ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSON(result, self.config, completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public static func getAll(_ config: Config, _ completion: @escaping (Result<[Indexes], Swift.Error>) -> Void) {
    Request(config).get(api: "/indexes") { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSONArray(result, config, completion)
      case .failure(let error):
        completion(.failure(error))
      }

    }

  }

  public static func getOrCreate(
    _ uid: String,
    primaryKey: String? = nil,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    Indexes.create(uid, primaryKey: primaryKey, config) { result in
      switch result {
      case .success(let index):
        completion(.success(index))
      case .failure(let error):
        switch error {
        case MeiliSearch.Error.meiliSearchApiError(_, let msErrorResponse, _, _):
          if let msErrorBody: MeiliSearch.MSErrorResponse  = msErrorResponse {
            if msErrorBody.errorCode == "index_already_exists" {
              Indexes(config, uid).get(completion)
            }
          } else {
            completion(.failure(error))
          }
        default:
          completion(.failure(error))
        }
      }
    }
  }

  public static func create(
    _ uid: String,
    primaryKey: String? = nil,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {

    let payload = CreateIndexPayload(uid: uid, primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    Request(config).post(api: "/indexes", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, config, completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func update(
    primaryKey: String,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {

    let payload: UpdateIndexPayload = UpdateIndexPayload(primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.put(api: "/indexes/\(self.uid)", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, self.config, completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func delete(
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {
    self.request.delete(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success:
        completion(.success(()))
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Codable

  private static func decodeJSON(
    _ data: Data,
    _ config: Config,
    _ completion: (Result<Indexes, Swift.Error>) -> Void) {
    do {
      let index: Index = try Constants.customJSONDecoder.decode(Index.self, from: data)
      let indexes: Indexes = Indexes(config, index.uid, primaryKey: index.primaryKey, index.createdAt, index.updatedAt)

      completion(.success(indexes))
    } catch {
      completion(.failure(error))
    }
  }

  private static func decodeJSONArray(
    _ data: Data,
    _ config: Config,
    _ completion: (Result<[Indexes], Swift.Error>) -> Void) {
    do {
      let rawIndexes: [Index] = try Constants.customJSONDecoder.decode([Index].self, from: data)
      var indexes: [Indexes] = []
      for rawIndex in rawIndexes {
          indexes.append(Indexes(config, rawIndex.uid, primaryKey: rawIndex.primaryKey, rawIndex.createdAt, rawIndex.updatedAt))
      }

      completion(.success(indexes))
    } catch {
      completion(.failure(error))
    }
  }

}

struct UpdateIndexPayload: Codable {
  let primaryKey: String
}

struct CreateIndexPayload: Codable {
  public let uid: String
  public let primaryKey: String?

  public init(
    uid: String,
    primaryKey: String? = nil
  ) {
    self.uid = uid
    self.primaryKey = primaryKey
  }
}
