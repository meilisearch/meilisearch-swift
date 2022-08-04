import Foundation

public class DocumentsQuery: Queryable {
  private var limit: Int?
  private var offset: Int?
  private var fields: [String]?

  init(limit: Int? = nil, offset: Int? = nil, fields: [String]? = nil) {
    self.offset = offset
    self.limit = limit
    self.fields = fields
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "offset": offset,
      "fields": fields != nil ? fields?.joined(separator: ",") : nil
    ]
  }
}
