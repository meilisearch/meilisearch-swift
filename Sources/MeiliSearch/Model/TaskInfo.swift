import Foundation

/**
 `TaskInfo` instances represent the current transaction status, use the `taskUid` value to
  verify the status of your transaction.
 */
public struct TaskInfo: Codable, Equatable {

  // MARK: Properties

  /// Unique ID for the current `TaskInfo`.
  public let uid: Int

  /// Unique ID for the current `TaskInfo`.
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: Task.Status

  /// Type of the task.
  public let type: String

  /// Date when the task has been enqueued.
  public let enqueuedAt: String

  static func == (lhs: TaskInfo, rhs: Task) -> Bool {
    lhs.uid == rhs.uid
  }

  public enum CodingKeys: String, CodingKey {
    case uid = "taskUid", indexUid, status, type, enqueuedAt
  }
}
