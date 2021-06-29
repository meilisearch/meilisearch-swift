import Foundation

/**
 Represent all error types in the client.
 */
public extension MeiliSearch {

  // MARK: Error

  /// Generic Error types for MeiliSearch,
  enum Error: Swift.Error, LocalizedError, Equatable {

    /// The client tried to contact the server but it was not found.
    case serverNotFound

    /// The client was able to connect the server, send the data nothing returned.
    case dataNotFound

    /// You custom host is invalid.
    case hostNotValid

    /// The input or output JSON is invalid.
    case invalidJSON

    /// Error originating from MeiliSearch API.
    // case meiliSearchApiError(message: String, errorCode: String, errorType: String, errorLink: String? = "http://docs.meilisearch.com/errors", underlying: Swift.Error)
    case meiliSearchApiError(message: String, msErrorResponse: MSErrorResponse?, statusCode: Int = 0, url: String = "")

    /// Error communicating with MeiliSearch API.
    case meiliSearchCommunicationError(message: String, url: String)

    public var errorDescription: String? {
      switch self {
      case .serverNotFound:
        return "All hosts are unreachable."
      case .dataNotFound:
        return "Missing response data"
      case .hostNotValid:
        return "Response decoding failed"
      case .invalidJSON:
        return "Invalid json"
      case .meiliSearchCommunicationError(let message, let url):
        return "meiliSearchCommunicationError \(message) \(url) "

      // can we do let error and then error.message etc...
      case .meiliSearchApiError(let message, let error, let statusCode, let url):
        if let msErrorResponse = error as? MSErrorResponse {
         return "MeiliSearchApiError: \(msErrorResponse.message) \n errorCode: \(msErrorResponse.errorCode) \n errorType: \(msErrorResponse.errorType) \n errorLink: \(String(describing:msErrorResponse.errorLink)) \n status: \(statusCode) "
        }
        return "MeiliSearchApiError: \(String(describing:message)) - \(String(describing:statusCode)) - \(String(describing:url))"
      }
    }
  }
}
