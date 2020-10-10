import Foundation

/**
 `Update` instances represent the current transcation result, use the `updateId` value to 
 verify the status of your transaction.
 */
public struct Update: Codable, Equatable {

    // MARK: Properties

    /// The UID of the update.
    public let updateId: Int

    ///Result type for the Update.
    public struct Result: Codable, Equatable {

        // MARK: Properties

        ///Returns if the update has been sucessful or not.
        public let status: Status

        ///Unique ID for the current `Update`.
        public let updateId: Int

        ///Type of update.
        public let type: UpdateType

        ///Duration of the update process.
        public let duration: TimeInterval?

        ///Date when the update has been enqueued.
        public let enqueuedAt: Date

        ///Date when the update has been processed.
        public let processedAt: Date?

        ///Type of `Update`
        public struct UpdateType: Codable, Equatable {

            // MARK: Properties

            /// Name of update type.
            public let name: String

            /// ID of update type.
            public let number: Int

        }

    }

    public enum Status: Codable, Equatable {

        case enqueued
        case processed
        case failed

        public enum CodingError: Error {
            case unknownStatus
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawStatus = try container.decode(String.self)
            switch rawStatus {
            case "enqueued":
                self = .enqueued
            case "processed":
                self = .processed
            case "failed":
                self = .failed
            default:
                throw CodingError.unknownStatus
            }
        }

        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .enqueued:
                try container.encode("enqueued")
            case .processed:
                try container.encode("processed")
            case .failed:
                try container.encode("failed")
            }
        }

    }

}
