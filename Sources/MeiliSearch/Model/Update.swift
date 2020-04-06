import Foundation

/**
 `Update` instances represent the current transcation result, use the `updateId` value to 
 verify the status of your transaction.
 */
public struct Update: Codable, Equatable {

    // MARK: Properties

    /// The id of the update.
    public let updateId: Int

}
