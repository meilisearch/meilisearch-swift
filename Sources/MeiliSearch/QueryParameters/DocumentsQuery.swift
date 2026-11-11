import Foundation

/**
 `DocumentsQuery` contains pagination, field selection, and sorting options for a documents call.
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

  /// Ordered sorting criteria, such as `title:asc` or `id:desc` (Meilisearch v1.16 or later).
  /// Attributes must first be configured as sortable on the index.
  private var sort: [String]?

  // MARK: Initializers

  /// Creates a documents query. Omit `sort` to preserve the server's default document order.
  public init(limit: Int? = nil, offset: Int? = nil, fields: [String]? = nil, sort: [String]? = nil) {
    self.offset = offset
    self.limit = limit
    self.fields = fields
    self.sort = sort
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "offset": offset,
      "fields": fields != nil ? fields?.joined(separator: ",") : nil,
      "sort": sort?.joined(separator: ",")
    ]
  }
}
