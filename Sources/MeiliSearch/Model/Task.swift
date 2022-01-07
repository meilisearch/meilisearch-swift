import Foundation

/**
 `Task` instances represent the current transaction status, use the `uid` value to
  verify the status of your transaction.
 */
public struct Task: Codable, Equatable {

  // MARK: Properties

  /// The uid of the update.
  public let uid: Int
  public let indexUid: String
  public let status: Status
  public let type: String
  public let enqueuedAt: String

  public init(uid: Int, indexUid: String, status: Status, type: String, enqueuedAt: String) {
    self.uid = uid
    self.indexUid = indexUid
    self.status = status
    self.type = type
    self.enqueuedAt = enqueuedAt
  }

  /// Result type for the Update.
  public struct Result: Codable, Equatable {

    // MARK: Properties

    /// Returns if the update has been sucessful or not.
    public let status: Status

    /// Unique ID for the current `Update`.
    public let updateId: Int

    /// Type of update.
    public let type: UpdateType

    /// Duration of the update process.
    public let duration: TimeInterval?

    /// Date when the update has been enqueued.
    public let enqueuedAt: Date

    /// Date when the update has been processed.
    public let processedAt: Date?

    /// Type of `Update`.
    public struct UpdateType: Codable, Equatable {

      // MARK: Properties

      /// Name of update type.
      public let name: String

      /// ID of update type.
      public let number: Int?

    }
    /// Error information in case of failed update.
    public let error: MeiliSearch.MSErrorResponse?

  }

  public enum Status: Codable, Equatable {

    case enqueued
    case processing
    case succeeded
    case failed

    public enum StatusError: Error {
      case unknown
    }

    public init(from decoder: Decoder) throws {
      let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
      let rawStatus: String = try container.decode(String.self)
      switch rawStatus {
      case "enqueued":
        self = Status.enqueued
      case "processing":
        self = Status.processing
      case "succeeded":
        self = Status.succeeded
      case "failed":
        self = Status.failed
      default:
        throw StatusError.unknown
      }
    }

    public func encode(to encoder: Encoder) throws { }

  }

}
