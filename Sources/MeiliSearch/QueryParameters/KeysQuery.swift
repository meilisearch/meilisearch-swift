import Foundation

/**
 `KeysQuery` class represent the options used paginate and filter a documents call.
 */
public class KeysQuery: Queryable {
  // MARK: Properties

  /// Max number of indexes to be returned in one request.
  private var limit: Int?
  /// Offset the number of indexes that were skipped in the current response.
  private var offset: Int?

  init(limit: Int? = nil, offset: Int? = nil) {
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
