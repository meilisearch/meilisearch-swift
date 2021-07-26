import Foundation

/**
 `GetParameters` instances represent query setup for a documents fetch request.
 */
public struct GetParameters: Codable, Equatable {

  // MARK: Properties

  /// Number of documents to take.
  public let limit: Int?

  /// Number of documents to skip.
  public let offset: Int?

  /// Document attributes to show.
  public let attributesToRetrieve: [String]?

  // MARK: Initializers

  public init(
    offset: Int? = nil,
    limit: Int? = nil,
    attributesToRetrieve: [String]? = nil
  ) {
    self.offset = offset
    self.limit = limit
    self.attributesToRetrieve = attributesToRetrieve
  }

  func toQueryParameters() throws -> String {
    var queryParams = "?"
    if let offset: Int = self.offset {
      if queryParams != "?" {
        queryParams += "&"
      }
      queryParams += "offset=\(offset)"
    }

    if let limit: Int = self.limit {
      if queryParams != "?" {
        queryParams += "&"
      }
      queryParams += "limit=\(limit)"
    }

    if let attributesToRetrieve: [String] = self.attributesToRetrieve {
      if queryParams != "?" {
        queryParams += "&"
      }
      queryParams += "attributesToRetrieve=\(attributesToRetrieve.joined(separator: ","))"
    }

    if queryParams == "&" {
      return ""
    }
    return queryParams
  }
  // MARK: Codable Keys

  enum CodingKeys: String, CodingKey {
    case offset
    case limit
    case attributesToRetrieve
  }

}
