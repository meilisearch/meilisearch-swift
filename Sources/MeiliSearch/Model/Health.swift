import Foundation

/**
 `Health` instances represent the status of the MeiliSearch server.
 */
public struct Health: Codable, Equatable {

  // MARK: Properties

  /// Status of the MeiliSearch server
  public let status: String

}
