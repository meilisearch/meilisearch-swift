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
    _ keyParams: KeyParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let data: Data
    do {
      let encoder = JSONEncoder()
      data = try encoder.encode(keyParams)
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
    keyParams: KeyParams,
    _ completion: @escaping (Result<Key, Swift.Error>) -> Void) {
    let data: Data
    do {
      let encoder = JSONEncoder()
      data = try encoder.encode(keyParams)
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
}
