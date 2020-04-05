import Foundation

public struct SearchResult {
    public let hits: [[String: Any]]
    public let offset: Int
    public let limit: Int
    public let processingTimeMs: Int?
    public let query: String

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