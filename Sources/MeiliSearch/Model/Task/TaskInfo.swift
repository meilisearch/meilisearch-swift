import Foundation

/**
 `TaskInfo` instances represent the current transaction status, use the `taskUid` value to
  verify the status of your transaction.
 */
public struct TaskInfo: Codable, Equatable {
  /// Unique ID for the current `TaskInfo`.
  public let taskUid: Int

  /// Unique ID for the current `TaskInfo`.
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: MTask.Status

  /// Type of the task.
  public let type: TaskType

  /// Date when the task has been enqueued.
  public let enqueuedAt: Date

  public enum CodingKeys: String, CodingKey {
    case taskUid, indexUid, status, type, enqueuedAt
  }

  @discardableResult
  @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
  public func wait(on client: MeiliSearch, options: WaitOptions? = nil) async throws -> MTask {
    try await client.waitForTask(task: self, options: options)
  }
}
