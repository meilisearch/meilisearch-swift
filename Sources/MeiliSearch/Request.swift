import Foundation

/**
 Protocol that allows custom implementation of the HTTP layer.
 */
public protocol URLSessionProtocol {

  /// Result for the `execute` function.
  typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

  /// Function that will trigger the HTTP request.
  func execute(
    with request: URLRequest,
    completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

/// URLSessionDataTaskProtocol handler.
public protocol URLSessionDataTaskProtocol {
  /// Trigger HTTP request.
  func resume()
}

final class Request {
  private let config: Config
  private let session: URLSessionProtocol

  init(_ config: Config) {
    self.config = config
    self.session = config.session ?? URLSession.shared
  }

  func get(
    api: String,
    param: String? = nil,
    headers: [String: String] = [:],
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {

    autoreleasepool {
      var urlString: String = config.url(api: api)
      if let param: String = param, !param.isEmpty {
        urlString += param
      }

      guard let url: URL = URL(string: urlString) else {
        completion(.failure(MeiliSearch.Error.invalidURL(url: urlString)))
        return
      }

      var request: URLRequest = URLRequest(url: url)
      request.httpMethod = "GET"
      headers.forEach { (key, value) in
        request.addValue(value, forHTTPHeaderField: key)
      }

      if let apiKey = config.apiKey {
        request.addValue(apiKey, forHTTPHeaderField: "X-Meili-API-Key")
      }

      let task: URLSessionDataTaskProtocol = session.execute(with: request) { (data, response, error) in
        do {
          try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
          completion(.success(data))
          return
        } catch let error {
          completion(.failure(error))
          return
        }
      }

      task.resume()
    }
  }

  func post(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {

    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }

    var request: URLRequest = URLRequest(url: url)
    request.httpMethod = "POST"
    request.httpBody = data
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

    if let apiKey: String = config.apiKey {
      request.addValue(apiKey, forHTTPHeaderField: "X-Meili-API-Key")
    }

    let task: URLSessionDataTaskProtocol = session.execute(with: request) { (data, response, error) in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        if let unwrappedData: Data = data {
          completion(.success(unwrappedData))
          return
        }
        completion(.failure(MeiliSearch.Error.invalidJSON))
      } catch let error {
        completion(.failure(error))
        return
      }
    }

    task.resume()
  }

  func put(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {

    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }

    var request: URLRequest = URLRequest(url: url)
    request.httpMethod = "PUT"
    request.httpBody = data
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

    if let apiKey: String = config.apiKey {
      request.addValue(apiKey, forHTTPHeaderField: "X-Meili-API-Key")
    }

    let task: URLSessionDataTaskProtocol = session.execute(with: request) { (data, response, error) in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        if let unwrappedData: Data = data {
          completion(.success(unwrappedData))
          return
        }
        completion(.failure(MeiliSearch.Error.invalidJSON))
        return
      } catch let error {
        completion(.failure(error))
        return
      }
    }

    task.resume()
  }

  func delete(
    api: String,
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {
    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MeiliSearch.Error.invalidURL()))
      return
    }

    var request: URLRequest = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
    request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

    if let apiKey: String = config.apiKey {
      request.addValue(apiKey, forHTTPHeaderField: "X-Meili-API-Key")
    }

    let task: URLSessionDataTaskProtocol = session.execute(with: request) { (data, response, error) in
      do {
        try MeiliSearch.errorHandler(url: url, data: data, response: response, error: error)
        completion(.success(data))
        return
      } catch let error {
        completion(.failure(error))
        return
      }
    }
    task.resume()
  }
}

extension URLSession: URLSessionProtocol {
  public func execute(
    with request: URLRequest,
    completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
    self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
  }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
