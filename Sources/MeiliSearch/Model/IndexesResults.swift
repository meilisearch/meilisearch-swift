import Foundation

/**
 `IndexesResults` is a wrapper used in the indexes routes to handle the returned data.
 */

public struct IndexesResults: Codable, Equatable {
  public let results: [Index]
  public let offset: Int
  public let limit: Int
  public let total: Int
}
