import Foundation

/**
 `SearchParameters` instances represent query setup for a search request. 
 Use `SearchParameters.query` to directly create a search query with the
 default search configuration.
 */
public struct SearchParameters: Codable, Equatable {

    // MARK: Properties

    /// Query string (mandatory).
    public let query: String

    /// Number of documents to take.
    public let limit: Int

    /// Number of documents to skip.
    public let offset: Int

    /// Document attributes to show.
    public let attributesToRetrieve: [String]?

    /// Which attributes to crop.
    public let attributesToCrop: [String]

    /// Limit length at which to crop specified attributes.
    public let cropLength: Int

    /// Which attributes to highlight.
    public let attributesToHighlight: [String]

    /// Attribute with an exact match.
    public let filters: String?

    /// Select which attribute has to be filtered, useful when you need to narrow down the results of the filter.
    public let facetFilters: [[String]]?

    /// Retrieve the count of matching terms for each facets.
    public let facetsDistribution: [String]?

    /// Whether to return the raw matches or not.
    public let matches: Bool

    // MARK: Initializers

    init(
        query: String,
        offset: Int = Default.offset.rawValue,
        limit: Int = Default.limit.rawValue,
        attributesToRetrieve: [String]? = nil,
        attributesToCrop: [String] = [],
        cropLength: Int = Default.cropLength.rawValue,
        attributesToHighlight: [String] = [],
        filters: String? = nil,
        facetFilters: [[String]]? = nil,
        facetsDistribution: [String]? = nil,
        matches: Bool = false) {
        self.query = query
        self.offset = offset
        self.limit = limit
        self.attributesToRetrieve = attributesToRetrieve
        self.attributesToCrop = attributesToCrop
        self.cropLength = cropLength
        self.attributesToHighlight = attributesToHighlight
        self.filters = filters
        self.facetFilters = facetFilters
        self.facetsDistribution = facetsDistribution
        self.matches = matches
    }

    // MARK: Query Initializers

    /**
     Minimal static function used to easily initialize the `SearchParameters` instance with
     the search query applied.

     - parameter value: Query string (mandatory).
     */
    public static func query(_ value: String) -> SearchParameters {
        SearchParameters(query: value)
    }

    // MARK: Codable Keys

    enum CodingKeys: String, CodingKey {
        case query = "q"
        case offset
        case limit
        case attributesToRetrieve
        case attributesToCrop
        case cropLength
        case attributesToHighlight
        case filters
        case facetFilters
        case facetsDistribution
        case matches
    }

    // MARK: Default value for keys

    fileprivate enum Default: Int {
        case offset = 0
        case limit = 20
        case cropLength = 200
    }

}

extension SearchParameters {

    // MARK: Codable

    /// Encodes the `SearchParameters` to a JSON payload, removing any non necessary implicit parameter.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(query, forKey: .query)
        if limit != Default.limit.rawValue {
            try container.encode(limit, forKey: .limit)
        }
        if offset != Default.offset.rawValue {
            try container.encode(offset, forKey: .offset)
        }
        if let attributesToRetrieve: [String] = self.attributesToRetrieve, !attributesToRetrieve.isEmpty {
            try container.encode(attributesToRetrieve, forKey: .attributesToRetrieve)
        }
        if !attributesToCrop.isEmpty {
            try container.encode(attributesToCrop, forKey: .attributesToCrop)
        }
        if cropLength != Default.cropLength.rawValue {
            try container.encode(cropLength, forKey: .cropLength)
        }
        if !attributesToHighlight.isEmpty {
            try container.encode(attributesToHighlight, forKey: .attributesToHighlight)
        }
        if let filters: String = self.filters, !filters.isEmpty {
            try container.encode(filters, forKey: .filters)
        }
        if let facetFilters: [[String]] = self.facetFilters {
            try container.encode(facetFilters, forKey: .facetFilters)
        }
        if let facetsDistribution = self.facetsDistribution, !facetsDistribution.isEmpty {
            try container.encode(facetsDistribution, forKey: .facetsDistribution)
        }
        if matches {
            try container.encode(matches, forKey: .matches)
        }
    }

}
