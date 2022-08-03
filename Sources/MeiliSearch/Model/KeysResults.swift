import Foundation

/**
 `KeysResults` is a wrapper used in the indexes routes to handle the returned data.
 */

public struct KeysResults: Codable, Equatable {
  public let results: [Key]
  public let offset: Int
  public let limit: Int
  public let total: Int
}
