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

    // MARK: Codable Keys

    /**
    Codable key mapping
    */
    enum CodingKeys: String, CodingKey {
        case hits
        case offset
        case limit
        case nbHits
        case exhaustiveNbHits
        case facetsDistribution
        case exhaustiveFacetsCount
        case processingTimeMs
        case query
    }

    // MARK: Dynamic Codable

    /**
    `StringKey` internally used to decode the dynamic JSON used in the `facetsDistribution` value.
    */
    fileprivate struct StringKey: CodingKey {
        var stringValue: String
        init?(stringValue: String) {
            self.stringValue = stringValue
        }
        var intValue: Int? { nil }
        init?(intValue: Int) { nil }
    }

}

extension SearchResult {

    /// Decodes the JSON to a `SearchParameters` object, sets the default value if required.
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        hits = (try values.decodeIfPresent([T].self, forKey: .hits)) ?? []
        offset = try values.decode(Int.self, forKey: .offset)
        limit = try values.decode(Int.self, forKey: .limit)
        nbHits = try values.decode(Int.self, forKey: .nbHits)
        exhaustiveNbHits = try values.decodeIfPresent(Bool.self, forKey: .exhaustiveNbHits)
        exhaustiveFacetsCount = try values.decodeIfPresent(Bool.self, forKey: .exhaustiveFacetsCount)
        processingTimeMs = try values.decodeIfPresent(Int.self, forKey: .processingTimeMs)
        query = try values.decode(String.self, forKey: .query)

        //Behemoth ancient code below needed to dynamically decode the JSON
        if values.contains(.facetsDistribution) {
            let nested: KeyedDecodingContainer<StringKey> = try values.nestedContainer(keyedBy: StringKey.self, forKey: .facetsDistribution)
            var dic: [String: [String: Int]] = Dictionary(minimumCapacity: nested.allKeys.count)
            try nested.allKeys.forEach { (key: KeyedDecodingContainer<StringKey>.Key) in
                let facet: KeyedDecodingContainer<StringKey> = try nested.nestedContainer(keyedBy: StringKey.self, forKey: key)
                var inner: [String: Int] = Dictionary(minimumCapacity: facet.allKeys.count)
                try facet.allKeys.forEach { (innerKey: KeyedDecodingContainer<StringKey>.Key) in
                    inner[innerKey.stringValue] = try facet.decode(Int.self, forKey: innerKey)
                }
                dic[key.stringValue] = inner
            }
            facetsDistribution = dic
        } else {
            facetsDistribution = nil
        }

    }

}
