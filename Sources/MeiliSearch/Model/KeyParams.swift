import Foundation

/**
 `KeyParams` contains all the parameters to create an API key.
 */
public struct KeyParams: Codable, Equatable {
  public let description: String
  public let actions: [String]
  public let indexes: [String]
  public let expiresAt: String?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(description, forKey: .description)
    try container.encode(actions, forKey: .actions)
    try container.encode(indexes, forKey: .indexes)
    try container.encode(expiresAt, forKey: .expiresAt)
  }

  // MARK: Properties



}
