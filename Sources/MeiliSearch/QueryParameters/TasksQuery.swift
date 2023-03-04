import Foundation
/**
 `TasksQuery` class represent the options used to filter a get tasks call.
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
  /// Filter tasks response by a particular list of index Uids strings
  var indexUids: [String]

  private var uids: [Int]
  private var canceledBy: [Int]
  private var beforeEnqueuedAt: Date?
  private var afterEnqueuedAt: Date?
  private var beforeStartedAt: Date?
  private var afterStartedAt: Date?
  private var beforeFinishedAt: Date?
  private var afterFinishedAt: Date?

  init(
    limit: Int? = nil, from: Int? = nil, next: Int? = nil,
    statuses: [String]? = nil, types: [String]? = nil,
    indexUids: [String]? = nil, uids: [Int]? = nil, canceledBy: [Int]? = nil,
    beforeEnqueuedAt: Date? = nil, afterEnqueuedAt: Date? = nil,
    afterFinishedAt: Date? = nil, beforeStartedAt: Date? = nil,
    afterStartedAt: Date? = nil, beforeFinishedAt: Date? = nil
  ) {
    self.from = from
    self.limit = limit
    self.next = next
    self.statuses = statuses ?? []
    self.types = types ?? []
    self.indexUids = indexUids ?? []
    self.uids = uids ?? []
    self.canceledBy = canceledBy ?? []
    self.beforeEnqueuedAt = beforeEnqueuedAt
    self.afterEnqueuedAt = afterEnqueuedAt
    self.beforeStartedAt = beforeStartedAt
    self.afterStartedAt = afterStartedAt
    self.beforeFinishedAt = beforeFinishedAt
    self.afterFinishedAt = afterFinishedAt
  }

  internal func buildQuery() -> [String: Codable?] {
    [
      "limit": limit,
      "from": from,
      "next": next,
      "uids": uids.isEmpty ? nil : uids.map(String.init).joined(separator: ","),
      "types": types.isEmpty ? nil : types.joined(separator: ","),
      "statuses": statuses.isEmpty ? nil : statuses.joined(separator: ","),
      "indexUids": indexUids.isEmpty ? nil : indexUids.joined(separator: ","),
      "canceledBy": canceledBy.isEmpty ? nil : canceledBy.map(String.init).joined(separator: ","),
      "beforeEnqueuedAt": Formatter.formatOptionalDate(date: beforeEnqueuedAt),
      "afterEnqueuedAt": Formatter.formatOptionalDate(date: afterEnqueuedAt),
      "beforeStartedAt": Formatter.formatOptionalDate(date: beforeStartedAt),
      "beforeFinishedAt": Formatter.formatOptionalDate(date: beforeFinishedAt),
      "afterFinishedAt": Formatter.formatOptionalDate(date: afterFinishedAt),
    ]
  }
}
