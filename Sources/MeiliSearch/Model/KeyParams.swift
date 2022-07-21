import Foundation

/**
 `KeyParams` contains all the parameters to create an API key.
 */
public struct KeyParams: Codable, Equatable {
  public let description: String
  public var name: String?
  public var uid: String?
  public let actions: [String]
  public let indexes: [String]
  public let expiresAt: String?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    if uid != nil {
      try container.encode(uid, forKey: .uid)
    }

    if name != nil {
      try container.encode(name, forKey: .name)
    }

    try container.encode(description, forKey: .description)
    try container.encode(actions, forKey: .actions)
    try container.encode(indexes, forKey: .indexes)
    try container.encode(expiresAt, forKey: .expiresAt)
  }

  // MARK: Properties
}

public struct KeyUpdateParams: Codable, Equatable {
  public var description: String?
  public var name: String?

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)

    if description != nil {
      try container.encode(description, forKey: .description)
    }

    if name != nil {
      try container.encode(name, forKey: .name)
    }
  }

  // MARK: Properties
}
