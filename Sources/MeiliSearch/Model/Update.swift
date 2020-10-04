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
        public let status: String

        ///Unique ID for the current `Update`.
        public let updateId: Int

        ///Type of update.
        public let type: Type

        ///Duration of the update process.
        public let duration: TimeInterval?

        ///Date when the update has been enqueued.
        public let enqueuedAt: Date

        ///Date when the update has been processed.
        public let processedAt: Date?

        enum CodingKeys: String, CodingKey {
            case status
            case updateId
            case type
            case duration
            case enqueuedAt
            case processedAt
        }

        ///Typr of `Update`.
        public struct `Type`: Codable, Equatable {

            // MARK: Properties

            /// Name of update type.
            public let name: String

            /// ID of update type.
            public let number: Int

            enum CodingKeys: String, CodingKey {
                case name
                case number
            }

        }

    }

}
