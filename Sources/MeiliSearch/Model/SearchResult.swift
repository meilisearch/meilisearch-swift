import Foundation

/**
 `SearchResult` instances represent result of a search.
 */
public struct SearchResult {

    // MARK: Properties

    /// Possible hints from the search query.
    public let hits: [[String: Any]]

    /// Number of documents skipped.
    public let offset: Int

    /// Number of documents taken.
    public let limit: Int

    /// Time, in milliseconds, to process the query.
    public let processingTimeMs: Int?

    /// Query string from the search.
    public let query: String

    // MARK: Initializers

    init(json: Any) {
        guard let dic = json as? [String: Any] else {
            fatalError()
        }
        hits = decodeHits(json: dic["hits"])
        offset = safeDictionaryEntry(dic, "offset", 0)
        limit = safeDictionaryEntry(dic, "limit", 0)
        processingTimeMs = dic["processingTimeMs"] as? Int
        query = dic["query"] as! String
    }

}

private func safeDictionaryEntry<T>(_ dic: [String: Any], _ key: String, _ defaultValue: T) -> T {
    let entry: Any? = dic[key]
    if let entry = entry as? T {
        return entry
    }
    return defaultValue
}

private func decodeHits(json: Any?) -> [[String: Any]] {
    guard let dic = json as? [[String: Any]] else {
        return [[:]]
    }
    return dic
}
