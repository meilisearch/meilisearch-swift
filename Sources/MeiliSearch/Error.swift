import Foundation

/**
 Represent all error types in the client.
 */
public extension MeiliSearch {

  // MARK: Error

  /// Generic Error types for MeiliSearch,
  enum Error: Swift.Error, LocalizedError {

    /// The client tried to contact the server but it was not found.
    case serverNotFound

    /// The client was able to connect the server, send the data nothing returned.
    case dataNotFound

    /// You custom host is invalid.
    case hostNotValid

    /// The input or output JSON is invalid.
    case invalidJSON

    /// Error originating from MeiliSearch API.
    case meiliSearchApiError(message: String, errorCode: String, errorType: String, errorLink: String? = "http://docs.meilisearch.com/errors", underlying: Swift.Error)

    /// Error communicating with MeiliSearch API.
    case meiliSearchCommunicationError

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
      case .meiliSearchCommunicationError:
        return "Error communicating with MeiliSearch"
      case .meiliSearchApiError(let message, let errorCode, let errorType, let errorLink, let underlying):
        return "All hosts are unreachable. message: \(message) errorcode: \(errorCode) \(errorType) \(errorLink) \(underlying)"
      }
    }
  }
}
