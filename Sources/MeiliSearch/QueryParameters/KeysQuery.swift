import Foundation

/**
 `KeysQuery` class represent the options used paginate and filter a keys call.
 */
public class KeysQuery: Queryable {
  // MARK: Properties

  /// Max number of keys to be returned in one request.
  private var limit: Int?
  /// Offset the number of keys that were skipped in the current response.
  private var offset: Int?

  public init(limit: Int? = nil, offset: Int? = nil) {
    self.offset = offset
    self.limit = limit
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "offset": offset
    ]
  }
}
