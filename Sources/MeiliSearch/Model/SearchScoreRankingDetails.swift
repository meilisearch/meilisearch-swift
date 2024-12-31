import Foundation

public struct SearchScoreRankingDetails: Codable, Equatable {
  public enum MatchType: String, Codable {
    case exactMatch, matchesStart, noExactMatch
  }
  
  public let order: Int
  public let score: Double?
  public let maxTypoCount: Int?
  public let typoCount: Int?
  public let maxMatchingWords: Int?
  public let matchingWords: Int?
  public let value: String?
  public let matchType: MatchType?
  public let queryWordDistanceScore: Double?
  public let attributeRankingOrderScore: Double?
}
