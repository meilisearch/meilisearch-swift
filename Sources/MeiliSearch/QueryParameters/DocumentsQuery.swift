import Foundation

/**
 `DocumentsQuery` class represent the options used paginate and filter a documents call.
 */
public class DocumentsQuery: Queryable {
  // MARK: Properties

  /// Max number of documents to be returned in one request.
  private var limit: Int?
  /// Offset the number of documents that were skipped in the current response.
  private var offset: Int?
  /// List of fields that should be returned in the response.
  /// Be careful with this option, since `T` should be able to handle the missing fields.
  private var fields: [String]?

  // MARK: Initializers

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
