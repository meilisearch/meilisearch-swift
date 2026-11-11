import Foundation

/**
 Settings controlling the number and order of facet values.
 */
public struct Faceting: Codable, Equatable {
  /// Maximum number of values returned for each facet.
  public let maxValuesPerFacet: Int?

  /// Sort order by attribute name. `*` supplies the fallback for other attributes.
  public let sortFacetValuesBy: [String: SortOrder]?

  public enum SortOrder: String, Codable {
    /// Sort facet values alphabetically.
    case alpha
    /// Sort facet values by their exact document count.
    case count
    /// Sort facet values by their sampled document count (Meilisearch v1.56 or later).
    case sampledCount
  }

  public init(maxValuesPerFacet: Int? = nil, sortFacetValuesBy: [String: SortOrder]? = nil) {
    self.maxValuesPerFacet = maxValuesPerFacet
    self.sortFacetValuesBy = sortFacetValuesBy
  }
}
