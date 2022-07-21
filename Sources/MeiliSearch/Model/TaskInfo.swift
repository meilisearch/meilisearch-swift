import Foundation

/**
 `Task` instances represent the current transaction status, use the `uid` value to
  verify the status of your transaction.
 */
public struct TaskInfo: Codable, Equatable {

  // MARK: Properties

  /// Unique ID for the current `Task`.
  public let uid: Int

  /// Unique ID for the current `Task`.
  public let indexUid: String?

  /// Returns if the task has been successful or not.
  public let status: Task.Status

  /// Type of the task.
  public let type: String

  /// Details of the task.
//  public let details: Details?

  /// Duration of the task process.
//  public let duration: String?

  /// Date when the task has been enqueued.
  public let enqueuedAt: String

  /// Date when the task has been processed.
  // TODO: should this become a Date type?
//  public let processedAt: String?

  /// Type of `Task`.
    /// Error information in case of failed update.

  static func == (lhs: TaskInfo, rhs: Task) -> Bool {
    lhs.uid == rhs.uid
  }

  public enum CodingKeys: String, CodingKey {
    case uid = "taskUid", indexUid, status, type, enqueuedAt
  }

//  public enum Status: Codable, Equatable {
//
//    case enqueued
//    case processing
//    case succeeded
//    case failed
//
//    public enum StatusError: Error {
//      case unknown
//    }
//
//    public init(from decoder: Decoder) throws {
//      let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
//      let rawStatus: String = try container.decode(String.self)
//      switch rawStatus {
//      case "enqueued":
//        self = Status.enqueued
//      case "processing":
//        self = Status.processing
//      case "succeeded":
//        self = Status.succeeded
//      case "failed":
//        self = Status.failed
//      default:
//        throw StatusError.unknown
//      }
//    }
//
//    public func encode(to encoder: Encoder) throws { }
//
//  }

}
