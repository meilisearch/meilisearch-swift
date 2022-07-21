import Foundation

public class TasksQuery: Queryable {
  private var from: Int?
  private var limit: Int?
  private var next: Int?
  private var types: [String]
  var indexUid: [String]
  private var status: [String]

  init(limit: Int? = nil, from: Int? = nil, next: Int? = nil, status: [String]? = nil, types: [String]? = nil, indexUid: [String]? = nil) {
    self.from = from
    self.limit = limit
    self.next = next
    self.status = status ?? []
    self.types = types ?? []
    self.indexUid = indexUid ?? []
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "from": from,
      "next": next,
      "type": types.isEmpty ? nil : types.joined(separator: ","),
      "status": status.isEmpty ? nil : status.joined(separator: ","),
      "indexUid": indexUid.isEmpty ? nil : indexUid.joined(separator: ",")
    ]
  }
}
