import Foundation

/**
 Paginated dynamic search rule results.
 */
public struct DynamicSearchRulesResults: Codable, Equatable {
  public let results: [DynamicSearchRule]
  public let offset: Int
  public let limit: Int
  public let total: Int
}
