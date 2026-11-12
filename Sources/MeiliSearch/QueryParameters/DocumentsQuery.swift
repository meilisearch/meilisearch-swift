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

  /// Creates a documents query. Omit `sort` or pass an empty array to preserve the server's default document order.
  ///
  /// - Parameter sort: Ordered sorting criteria in `attribute:asc` or `attribute:desc` format,
  ///   such as `["title:asc", "id:desc"]`. Requires Meilisearch v1.16 or later and attributes
  ///   configured in the index's `sortableAttributes` setting.
  public init(limit: Int? = nil, offset: Int? = nil, fields: [String]? = nil, sort: [String]? = nil) {
    self.offset = offset
    self.limit = limit
    self.fields = fields
    self.sort = sort
  }

  internal func buildQuery() -> [String: Codable?] {
    let sortValue = sort.flatMap { criteria -> String? in
      guard !criteria.isEmpty else {
        return nil
      }
      let allowed = CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: "&=+#%"))
      return criteria.joined(separator: ",").addingPercentEncoding(withAllowedCharacters: allowed)
    }
    return [
      "limit": limit,
      "offset": offset,
      "fields": fields != nil ? fields?.joined(separator: ",") : nil,
      "sort": sortValue
    ]
  }
}
