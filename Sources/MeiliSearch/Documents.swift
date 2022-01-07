import Foundation

struct Documents {

  // MARK: Properties

  let request: Request

  // MARK: Initializers

  init (_ request: Request) {
    self.request = request
  }

  // MARK: Query

  func get<T>(
    _ uid: String,
    _ identifier: String,
    _ completion: @escaping (Result<T, Swift.Error>) -> Void)
  where T: Codable, T: Equatable {

    let query: String = "/indexes/\(uid)/documents/\(identifier)"
    request.get(api: query) { result in
      switch result {
      case .success(let data):
        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        Documents.decodeJSON(data, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func getAll<T>(
    _ uid: String,
    _ options: GetParameters? = nil,
    _ completion: @escaping (Result<[T], Swift.Error>) -> Void)
  where T: Codable, T: Equatable {
    do {
      var queryParameters = ""
      if let parameters: GetParameters = options {
        queryParameters = try parameters.toQueryParameters()
      }
      let query: String = "/indexes/\(uid)/documents\(queryParameters)"
      request.get(api: query) { result in
        switch result {
        case .success(let data):
          guard let data: Data = data else {
            completion(.failure(MeiliSearch.Error.dataNotFound))
            return
          }
          Documents.decodeJSON(data, completion: completion)

        case .failure(let error):
          completion(.failure(error))
        }
      }
    } catch let error {
      completion(.failure(error))
    }
  }

  // MARK: Write

  func add(
    _ uid: String,
    _ document: Data,
    _ primaryKey: String? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {

    var query: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      query += "?primaryKey=\(primaryKey)"
    }

    request.post(api: query, document) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func add<T>(
    _ uid: String,
    _ documents: [T],
    _ encoder: JSONEncoder? = nil,
    _ primaryKey: String? =  nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) where T: Encodable {

    var query: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      query += "?primaryKey=\(primaryKey)"
    }

    let data: Data!
    switch encodeJSON(documents, encoder) {
    case .success(let documentData):
      data = documentData
    case .failure(let error):
      completion(.failure(error))
      return
    }

    request.post(api: query, data) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func update(
    _ uid: String,
    _ document: Data,
    _ primaryKey: String? = nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {

    var query: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      query += "?primaryKey=\(primaryKey)"
    }

    request.put(api: query, document) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func update<T>(
    _ uid: String,
    _ documents: [T],
    _ encoder: JSONEncoder? = nil,
    _ primaryKey: String? =  nil,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) where T: Encodable {

    var query: String = "/indexes/\(uid)/documents"
    if let primaryKey: String = primaryKey {
      query += "?primaryKey=\(primaryKey)"
    }

    let data: Data!
    switch encodeJSON(documents, encoder) {
    case .success(let documentData):
      data = documentData
    case .failure(let error):
      completion(.failure(error))
      return
    }

    request.put(api: query, data) { result in
      switch result {
      case .success(let data):
        Documents.decodeJSON(data, completion: completion)
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Delete

  func delete(
    _ uid: String,
    _ identifier: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/documents/\(identifier)") { result in

      switch result {
      case .success(let result):

        guard let result: Data = result else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Documents.decodeJSON(result, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func deleteAll(
    _ uid: String,
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/documents") { result in

      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        Documents.decodeJSON(data, completion: completion)

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func deleteBatch(
    _ uid: String,
    _ documentsIdentifiers: [Int],
    _ completion: @escaping (Result<Task, Swift.Error>) -> Void) {

    let data: Data

    do {
      data = try JSONSerialization.data(withJSONObject: documentsIdentifiers, options: [])
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    self.request.post(api: "/indexes/\(uid)/documents/delete-batch", data) { result in

      switch result {
      case .success(let data):

        Documents.decodeJSON(data, completion: completion)

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
      let decoder: JSONDecoder = customDecoder ?? Constants.customJSONDecoder
      let value: T = try decoder.decode(T.self, from: data)
      completion(.success(value))
    } catch {
      completion(.failure(error))
    }
  }

  private func encodeJSON<T: Encodable>(
    _ documents: [T],
    _ encoder: JSONEncoder?) -> Result<Data, Swift.Error> {
    do {
      let data: Data = try (encoder ?? Constants.customJSONEecoder)
        .encode(documents)
      return .success(data)
    } catch {
      return .failure(error)
    }
  }

}
