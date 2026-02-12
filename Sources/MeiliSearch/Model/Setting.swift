import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
  Settings object provided by the user
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

  /// Settings for typo tolerance
  public let typoTolerance: TypoTolerance?

  /// Precision level when calculating the proximity ranking rule
  public let proximityPrecision: ProximityPrecision?

  /// Maximum duration of a search query
  public let searchCutoffMs: Int?

  /// List of tokens that will be considered as word separators by Meilisearch.
  public let separatorTokens: [String]?

  /// List of tokens that will not be considered as word separators by Meilisearch.
  public let nonSeparatorTokens: [String]?

  /// List of words on which the segmentation will be overridden.
  public let dictionary: [String]?

  /// Pagination settings for the current index
  public let pagination: Pagination?

  /// Whether facet search is enabled
  public let facetSearch: Bool?

  /// Prefix search behavior: "indexingTime" or "disabled"
  public let prefixSearch: String?

  // MARK: Initializers

  public init(
    rankingRules: [String]? = nil,
    searchableAttributes: [String]? = nil,
    displayedAttributes: [String]? = nil,
    stopWords: [String]? = nil,
    synonyms: [String: [String]]? = nil,
    distinctAttribute: String? = nil,
    filterableAttributes: [String]? = nil,
    sortableAttributes: [String]? = nil,
    separatorTokens: [String]? = nil,
    nonSeparatorTokens: [String]? = nil,
    dictionary: [String]? = nil,
    pagination: Pagination? = nil,
    typoTolerance: TypoTolerance? = nil,
    proximityPrecision: ProximityPrecision? = nil,
    searchCutoffMs: Int? = nil,
    facetSearch: Bool? = nil,
    prefixSearch: String? = nil
    ) {
    self.rankingRules = rankingRules
    self.searchableAttributes = searchableAttributes
    self.displayedAttributes = displayedAttributes
    self.stopWords = stopWords
    self.synonyms = synonyms
    self.distinctAttribute = distinctAttribute
    self.filterableAttributes = filterableAttributes
    self.sortableAttributes = sortableAttributes
    self.nonSeparatorTokens = nonSeparatorTokens
    self.separatorTokens = separatorTokens
    self.dictionary = dictionary
    self.pagination = pagination
    self.typoTolerance = typoTolerance
    self.proximityPrecision = proximityPrecision
    self.searchCutoffMs = searchCutoffMs
    self.facetSearch = facetSearch
    self.prefixSearch = prefixSearch
  }
}
