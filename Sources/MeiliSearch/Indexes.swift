import Foundation

public struct Indexes {

  // MARK: Properties

  let request: Request
  let config: Config
  // let uid: String?

  /// The index UID.
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
    _ createdAt: Date? = nil,
    _ updatedAt: Date? = nil,
    _ primaryKey: String? = nil) {
    self.config = config
    self.request = Request(self.config)
    self.uid = uid
    self.createdAt = createdAt
    self.updatedAt = updatedAt
    self.primaryKey = primaryKey
  }

  enum CodingKeys: String, CodingKey {
    case UID = "uid"
    case createdAt
    case updatedAt
    case primaryKey
  }

  // MARK: Functions

  func get(
    _ UID: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

    self.request.get(api: "/indexes/\(UID)") { result in

      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSON(result, completion, self.config)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public func get2(_ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(self.uid)") { result in
      switch result {
      case .success(let result):
        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Indexes.decodeJSON2(result, self.config, completion)
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

  // func getOrCreate(_ UID: String, _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {
  //   self.create(UID) { result in
  //     switch result {
  //     case .success(let index):
  //       completion(.success(index))
  //     case .failure(let error):
  //       switch error {
  //       case MeiliSearch.Error.meiliSearchApiError(_, let msErrorResponse, _, _):
  //         if let msErrorBody: MeiliSearch.MSErrorResponse  = msErrorResponse {
  //           if msErrorBody.errorCode == "index_already_exists" {
  //             self.get(UID, completion)
  //           }
  //         } else {
  //           completion(.failure(error))
  //         }
  //       default:
  //         completion(.failure(error))
  //       }
  //     }
  //   }
  // }

  public static func getOrCreate2(
    _ UID: String,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {
    Indexes.create2(UID, config) { result in
      switch result {
      case .success(let index):
        completion(.success(index))
      case .failure(let error):
        switch error {
        case MeiliSearch.Error.meiliSearchApiError(_, let msErrorResponse, _, _):
          if let msErrorBody: MeiliSearch.MSErrorResponse  = msErrorResponse {
            if msErrorBody.errorCode == "index_already_exists" {
              Indexes(config, UID).get2(completion)
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

  func create(
    _ UID: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

    let payload: CreateIndexPayload = CreateIndexPayload(uid: UID)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.post(api: "/indexes", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, completion, self.config)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  public static func create2(
    _ UID: String,
    _ config: Config,
    _ completion: @escaping (Result<Indexes, Swift.Error>) -> Void) {

    let payload: CreateIndexPayload = CreateIndexPayload(uid: UID)
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
        Indexes.decodeJSON2(result, config, completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func update(
    _ UID: String,
    _ primaryKey: String,
    _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

    let payload: UpdateIndexPayload = UpdateIndexPayload(primaryKey: primaryKey)
    let data: Data
    do {
      data = try JSONEncoder().encode(payload)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.put(api: "/indexes/\(UID)", data) { result in
      switch result {
      case .success(let result):
        Indexes.decodeJSON(result, completion, self.config)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func delete(
    _ UID: String,
    _ completion: @escaping (Result<(), Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(UID)") { result in

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
    _ completion: (Result<Index, Swift.Error>) -> Void,
    _ config: Config) {
    do {
      let index: Index = try Constants.customJSONDecoder.decode(Index.self, from: data)
      // let indexes: Indexes = try Indexes(config, index.UID, index.createdAt, index.updatedAt, index.primaryKey)

      completion(.success(index))
    } catch {
      completion(.failure(error))
    }
  }

  private static func decodeJSON2(
    _ data: Data,
    _ config: Config,
    _ completion: (Result<Indexes, Swift.Error>) -> Void) {
    do {
      let index: Index = try Constants.customJSONDecoder.decode(Index.self, from: data)
      let indexes: Indexes = Indexes(config, index.UID, index.createdAt, index.updatedAt, index.primaryKey)

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
          indexes.append(Indexes(config, rawIndex.UID, rawIndex.createdAt, rawIndex.updatedAt, rawIndex.primaryKey))
      }

      completion(.success(indexes))
    } catch {
      completion(.failure(error))
    }
  }

}

struct CreateIndexPayload: Codable {
  let uid: String
}

struct UpdateIndexPayload: Codable {
  let primaryKey: String
}
