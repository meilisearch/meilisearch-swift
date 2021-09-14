import Foundation

/**
  Settings object provided byb the user
 */
public struct Setting: Codable, Equatable {

  // MARK: Properties

  /// List of ranking rules for a given `Index`.
  public let rankingRules: [String]?

  /// List of searchable attributes for a given `Index`.
  public let searchableAttributes: [String]?

  /// List of displayed attributes for a given `Index`.
  public let displayedAttributes: [String]?

  /// List of stop-words for a given `Index`.
  public let stopWords: [String]?

  /// List of synonyms and its values for a given `Index`.
  public let synonyms: [String: [String]]?

  /// Optional distinct attribute set for a given `Index`.
  public let distinctAttribute: String?

  /// List of attributes used for filtering
  public let filterableAttributes: [String]?

  /// List of attributes used for sorting
  public let sortableAttributes: [String]?

  // MARK: Initializers

  public init(
    rankingRules: [String]? = nil,
    searchableAttributes: [String]? = nil,
    displayedAttributes: [String]? = nil,
    stopWords: [String]? = nil,
    synonyms: [String: [String]]? = nil,
    distinctAttribute: String? = nil,
    filterableAttributes: [String]? = nil,
    sortableAttributes: [String]? = nil
    ) {
    self.rankingRules = rankingRules
    self.searchableAttributes = searchableAttributes
    self.displayedAttributes = displayedAttributes
    self.stopWords = stopWords
    self.synonyms = synonyms
    self.distinctAttribute = distinctAttribute
    self.filterableAttributes = filterableAttributes
    self.sortableAttributes = sortableAttributes
  }

  enum CodingKeys: String, CodingKey {
    case rankingRules
    case searchableAttributes
    case displayedAttributes
    case stopWords
    case synonyms
    case distinctAttribute
    case filterableAttributes
    case sortableAttributes
  }

}
