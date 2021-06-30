import Foundation

struct Indexes {

  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
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

        Indexes.decodeJSON(result, completion)

      case .failure(let error):
        completion(.failure(error))
      }

    }

  }

  func getAll(_ completion: @escaping (Result<[Index], Swift.Error>) -> Void) {

    self.request.get(api: "/indexes") { result in

      switch result {
      case .success(let result):

        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Indexes.decodeJSONArray(result, completion)

      case .failure(let error):
        completion(.failure(error))
      }

    }

  }

  func getOrCreate(_ UID: String, _ completion: @escaping (Result<Index, Swift.Error>) -> Void) {

    self.create(UID) { result in

      switch result {

      case .success(let index):
        completion(.success(index))

      case .failure(let error):
        switch error {
        case CreateError.indexAlreadyExists:
          self.get(UID, completion)
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

        Indexes.decodeJSON(result, completion)

      case .failure(let error):

        switch error {
        case let msError as MSError:
          completion(.failure(CreateError.decode(msError)))
        default:
          completion(.failure(error))
        }

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

        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Indexes.decodeJSON(result, completion)

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
    _ completion: (Result<Index, Swift.Error>) -> Void) {
    do {
      let index: Index = try Constants.customJSONDecoder.decode(Index.self, from: data)

      completion(.success(index))
    } catch {
      completion(.failure(error))
    }
  }

  private static func decodeJSONArray(
    _ data: Data,
    _ completion: (Result<[Index], Swift.Error>) -> Void) {
    do {
      let indexes: [Index] = try Constants.customJSONDecoder.decode([Index].self, from: data)

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

/**
 Error type for all functions included in the `Indexes` struct.
 */
public enum CreateError: Swift.Error, Equatable {

  // MARK: Values

  /// Case the `Index` already exists in the Meilisearch instance, this error will return.
  case indexAlreadyExists

  // MARK: Codable

  static func decode(_ error: MSError) -> Swift.Error {

    let underlyingError: NSError = error.underlying as NSError

    if let data: Data = error.data {

      let msErrorResponse: MSErrorResponse?
      do {
        let decoder: JSONDecoder = JSONDecoder()
        msErrorResponse = try decoder.decode(MSErrorResponse.self, from: data)
      } catch {
        msErrorResponse = nil
      }

      if underlyingError.code == 400 && msErrorResponse?.errorType == "invalid_request_error" && msErrorResponse?.errorCode == "index_already_exists" {
        return CreateError.indexAlreadyExists
      }
      return error

    }

    return error
  }
}
