import Foundation

/**
 `Update` instances represent the current transcation result, use the `updateId` value to 
 verify the status of your transaction.
 */
public struct Update: Codable, Equatable {

    // MARK: Properties

    /// The UID of the update.
    public let updateId: Int

    public struct Result: Codable, Equatable {

        // MARK: Properties

        public let status: String

        public let updateId: Int

        public let type: Type

        public let duration: TimeInterval

        public let enqueuedAt: Date

        public let processedAt: Date

        public struct `Type`: Codable, Equatable {

            // MARK: Properties

            public let name: String

            public let number: Int

        }

    }

}
