/**
 `Queryable` protocol that transforms options used to paginate and filter in HTTP requests.
 */
internal protocol Queryable {
  /// Function that should result in an Dictionary that will be used to create a valid query string from the non-nil values.
  func buildQuery() -> [String: Codable?]
}

extension Queryable {
  /// Transform a `Queryable` instance into a valid HTTP query string.
  func toQuery() -> String {
    let query: [String: Codable?] = buildQuery()

    let data = query.compactMapValues { $0 }
      .sorted { $0.key < $1.key }
      .map { "\($0)=\($1)" }
      .joined(separator: "&")

    if !data.isEmpty {
      return "?\(data)"
    }

    return data
  }
}
