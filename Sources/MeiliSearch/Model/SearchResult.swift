import Foundation

/**
 `SearchResult` instances represent result of a search.
 */
public struct SearchResult<T>: Codable, Equatable where T: Codable, T: Equatable  {

    // MARK: Properties

    /// Possible hints from the search query.
    public let hits: [T]

    /// Number of documents skipped.
    public let offset: Int

    /// Number of documents taken.
    public let limit: Int

    /// Time, in milliseconds, to process the query.
    public let processingTimeMs: Int?

    /// Query string from the search.
    public let query: String

}
