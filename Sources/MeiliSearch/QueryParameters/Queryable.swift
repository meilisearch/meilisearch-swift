internal protocol Queryable {
  func buildQuery() -> [String: Codable?]
}

extension Queryable {
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
