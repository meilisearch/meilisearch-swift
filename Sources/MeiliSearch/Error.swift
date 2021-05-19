import Foundation

/**
 Represent all error types in the client.
*/
public extension MeiliSearch {

  // MARK: Error

  /// Generic Error types for MeiliSearch,
  enum Error: Swift.Error {

    /// The client tried to contact the server but it was not found.
    case serverNotFound

    /// The client was able to connect the server, send the data nothing returned.
    case dataNotFound

    /// You custom host is invalid.
    case hostNotValid

    /// The input or output JSON is invalid.
    case invalidJSON
  }

}

/// Allow use of error comparasion for the MeiliSearch.Error type.
extension MeiliSearch.Error: Equatable {}
