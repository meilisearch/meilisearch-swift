import Foundation

  /// Result type for the Update.
  public struct TaskResult: Codable, Equatable {

    // MARK: Properties

    /// Unique ID for the current `Update`.
    public let uid: Int

    /// Unique ID for the current `Update`.
    public let indexUid: String

    /// Returns if the update has been sucessful or not.
    public let status: Task.Status

    /// Type of update.
    public let type: String

    /// Type of update.
    public let details: Details?

    /// Duration of the update process.
    public let duration: String?

    /// Date when the update has been enqueued.
    public let enqueuedAt: String

    /// Date when the update has been processed.
    // TODO: should this become a Date type?
    public let processedAt: String?

    /// Type of `Update`.
    public struct Details: Codable, Equatable {

      // MARK: Properties

      // Number of documents sent
      public let receivedDocuments: Int?

      // Number of documents successfully indexed/updated in Meilisearch
      public let indexedDocuments: Int?

      // Number of deleted documents
      public let deletedDocuments: Int?

      // Primary key on index creation
      public let primaryKey: String?

      //

    }
    /// Error information in case of failed update.
    public let error: MeiliSearch.MSErrorResponse?

  }
