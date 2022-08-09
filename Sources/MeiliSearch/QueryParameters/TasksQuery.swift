import Foundation
/**
 `TasksQuery` class represent the options used paginate and filter a tasks call.
 */

public class TasksQuery: Queryable {
  // MARK: Properties

  /// Integer value representing the first `uid` of the first task returned.
  private var from: Int?
  /// Max number of indexes to be returned in one request.
  private var limit: Int?
  /// Integer value used to retrieve the next batch of tasks.
  private var next: Int?
  /// List of strings with all the types the response should contain.
  private var types: [String]
  /// List of strings with all the statuses the response should contain.
  private var status: [String]

  var indexUid: [String]

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
