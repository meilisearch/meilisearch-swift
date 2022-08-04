import Foundation

public class IndexesQuery: Queryable {
  private var limit: Int?
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
