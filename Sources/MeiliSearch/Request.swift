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

public enum MSHTTPError: Swift.Error {
  case invalidURL
}

struct MSError: Swift.Error {
  let data: Data?
  let underlying: Swift.Error
}

struct MeiliSearchApiError: Swift.Error {
    let message: String
    let errorCode: String
    let errorType: String
    let errorLink: String?
    let underlying: Swift.Error
}

struct MSErrorResponse: Decodable {
  let message: String
  let errorCode: String
  let errorType: String
  let errorLink: String?
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
        completion(.failure(MSHTTPError.invalidURL))
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
        if let error: Swift.Error = error {
          completion(
            .failure(
              MeiliSearch.Error.meiliSearchCommunicationError(
                message: error.localizedDescription,
                url: url.absoluteString
              )
            )
          )
          return
        }

        guard let response = response as? HTTPURLResponse else {
          fatalError("Correct handles invalid response, please create a custom error type")
        }

        // Test not custom function
        if let res: MSErrorResponse = try? Constants.customJSONDecoder.decode(MSErrorResponse.self, from: data!) {
          completion(
            .failure(
              MeiliSearch.Error.meiliSearchApiError(
                message: res.message,
                msErrorResponse: MSErrorResponse(
                  message: res.message,
                  errorCode: res.errorCode,
                  errorType: res.errorType,
                  errorLink: res.errorLink
                ),
                statusCode: response.statusCode,
                url: url.absoluteString                            )
            )
          )
          return
        }

        if 400 ... 599 ~= response.statusCode {
          completion(
            .failure(
              MeiliSearch.Error.meiliSearchApiError(
                message: HTTPURLResponse.localizedString(forStatusCode: response.statusCode),
                msErrorResponse: nil,
                statusCode: response.statusCode,
                url: url.absoluteString
              )
            )
          )
          return
        }

        completion(.success(data))
      }

      task.resume()
    }
  }

  func post(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data, Swift.Error>) -> Void) {

    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MSHTTPError.invalidURL))
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
      if let error: Swift.Error = error {
        let msError: MSError = MSError(data: data, underlying: error)
        completion(.failure(msError))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        fatalError("Correct handles invalid response, please create a custom error type")
      }

      if 400 ... 599 ~= response.statusCode {
        completion(.failure(
          MSError(
            data: data,
            underlying: NSError(domain: "HttpStatus", code: response.statusCode, userInfo: nil))))
        return
      }

      guard let data = data else {
        return
      }

      completion(.success(data))
    }

    task.resume()

  }

  func put(
    api: String,
    _ data: Data,
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {

    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MSHTTPError.invalidURL))
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
      if let error: Swift.Error = error {
        completion(.failure(error))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        fatalError("Correct handles invalid response, please create a custom error type")
      }

      if 400 ... 599 ~= response.statusCode {
        completion(.failure(
          MSError(
            data: data,
            underlying: NSError(domain: "HttpStatus", code: response.statusCode, userInfo: nil))))
        return
      }

      completion(.success(data))
    }

    task.resume()

  }

  func delete(
    api: String,
    _ completion: @escaping (Result<Data?, Swift.Error>) -> Void) {

    guard let url: URL = URL(string: config.url(api: api)) else {
      completion(.failure(MSHTTPError.invalidURL))
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
      if let error: Swift.Error = error {
        completion(.failure(error))
        return
      }

      guard let response = response as? HTTPURLResponse else {
        fatalError("Correct handles invalid response, please create a custom error type")
      }

      if 400 ... 599 ~= response.statusCode {
        completion(.failure(
          MSError(
            data: data,
            underlying: NSError(domain: "HttpStatus", code: response.statusCode, userInfo: nil))))
        return
      }

      completion(.success(data))
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
