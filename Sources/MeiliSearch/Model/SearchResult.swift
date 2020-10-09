import Foundation

/**
 `SearchResult` instances represent the result of a search.
 Requires that the value `T` conforms to the `Codable` and `Equatable` protocols.
 */
public struct SearchResult<T>: Codable, Equatable where T: Codable, T: Equatable {

    // MARK: Properties

    /// Possible hints from the search query.
    public let hits: [T]

    /// Number of documents skipped.
    public let offset: Int

    /// Number of documents taken.
    public let limit: Int

    /// Total number of matches,
    public let nbHits: Int

    /// Whether `nbHits` is exhaustive.
    public let exhaustiveNbHits: Bool?

    /// Distribution of the given facets.
    public let facetsDistribution: [String: [String: Int]]?

    /// Whether facetDistribution is exhaustive.
    public let exhaustiveFacetsCount: Bool?

    /// Time, in milliseconds, to process the query.
    public let processingTimeMs: Int?

    /// Query string from the search.
    public let query: String

}
