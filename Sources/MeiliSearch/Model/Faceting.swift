import Foundation

/**
 Settings controlling the number and order of facet values.
 */
public struct Faceting: Codable, Equatable {
  /// Maximum number of values returned for each facet.
  public let maxValuesPerFacet: Int?

  /// Sort order by attribute name. `*` supplies the fallback for other attributes.
  public let sortFacetValuesBy: [String: SortOrder]?

  /// Ordering applied to the values returned for a facet.
  public enum SortOrder: String, Codable {
    /// Sort facet values alphabetically.
    case alpha
    /// Sort facet values by their exact document count.
    case count
    /// Sort facet values by their sampled document count (Meilisearch v1.56 or later).
    case sampledCount
  }

  /// Creates faceting settings for a partial update. Nil properties are omitted from the request.
  ///
  /// - Parameters:
  ///   - maxValuesPerFacet: Maximum number of values to return for each facet.
  ///     Leave nil to preserve the index's current limit when updating.
  ///   - sortFacetValuesBy: Sort orders keyed by attribute name. Use `*` as the fallback
  ///     for other attributes. The `sampledCount` order requires Meilisearch v1.56 or later.
  public init(maxValuesPerFacet: Int? = nil, sortFacetValuesBy: [String: SortOrder]? = nil) {
    self.maxValuesPerFacet = maxValuesPerFacet
    self.sortFacetValuesBy = sortFacetValuesBy
  }
}
