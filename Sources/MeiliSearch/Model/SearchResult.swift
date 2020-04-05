import Foundation

public struct SearchResult {
    let hits: [[String: Any]]
    let offset: Int
    let limit: Int
    let processingTimeMs: Int
    let query: String

    init(json: Any) {
        guard let dic = json as? [String: Any] else {
            fatalError()
        }
        hits = decodeHits(json: dic["hits"])
        offset = dic["offset"] as! Int
        limit = dic["limit"] as! Int
        processingTimeMs = dic["processingTimeMs"] as! Int
        query = dic["query"] as! String
    }

}

private func decodeHits(json: Any) -> [[String: Any]] {
    guard let dic = json as? [[String: Any]] else {
        return [[:]]
    }
    return dic
}