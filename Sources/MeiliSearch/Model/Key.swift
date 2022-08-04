import Foundation

/**
 Each key has a given set of permissions on the API routes.
 */
public struct Key: Codable, Equatable {
  // MARK: Properties

  public let uid: String
  public let name: String?
  public let description: String?
  public let key: String
  public let actions: [String]
  public let indexes: [String]
  public let expiresAt: String?
  public let createdAt: String
  public let updatedAt: String
}
