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
  private var statuses: [String]

  var indexUids: [String]

  init(limit: Int? = nil, from: Int? = nil, next: Int? = nil, statuses: [String]? = nil, types: [String]? = nil, indexUids: [String]? = nil) {
    self.from = from
    self.limit = limit
    self.next = next
    self.statuses = statuses ?? []
    self.types = types ?? []
    self.indexUids = indexUids ?? []
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "from": from,
      "next": next,
      "type": types.isEmpty ? nil : types.joined(separator: ","),
      "status": statuses.isEmpty ? nil : statuses.joined(separator: ","),
      "indexUids": indexUids.isEmpty ? nil : indexUids.joined(separator: ",")
    ]
  }
}
