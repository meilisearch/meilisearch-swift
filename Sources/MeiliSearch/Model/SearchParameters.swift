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

    /// Number of documents to skip.
    public let offset: Int

    /// Number of documents to take.
    public let limit: Int

    /// Document attributes to show.
    public let attributesToRetrieve: [String]?

    /// Which attributes to crop.
    public let attributesToCrop: [String]

    /// Limit length at which to crop specified attributes.
    public let cropLength: Int
    
    /// Which attributes to highlight.
    public let attributesToHighlight: [String]

    /// Attribute with an exact match.
    public let filters: Filter?

    /// Whether to return the raw matches or not.
    public let matches: Bool

    // MARK: Initializers

    init(
        query: String,
        offset: Int = 0,
        limit: Int = 20,
        attributesToRetrieve: [String]? = nil,
        attributesToCrop: [String] = [],
        cropLength: Int = 200,
        attributesToHighlight: [String] = [],
        filters: Filter? = nil,
        matches: Bool = false) {
        self.query = query
        self.offset = offset
        self.limit = limit
        self.attributesToRetrieve = attributesToRetrieve
        self.attributesToCrop = attributesToCrop
        self.cropLength = cropLength
        self.attributesToHighlight = attributesToHighlight
        self.filters = filters
        self.matches = matches
    }

    // MARK Query Initializers

    /**
     Minimal static function used to easily initialize the `SearchParameters` instance with
     the search query applied.

     - parameter value: Query string (mandatory).
     */
    public static func query(_ value: String) -> SearchParameters {
        SearchParameters(query: value)
    }

    func dictionary() -> [String: String] {
      var dic = [String: String]()
      dic["q"] = query
      dic["offset"] = "\(offset)"
      dic["limit"] = "\(limit)"

      if let attributesToRetrieve = self.attributesToRetrieve {
        dic["attributesToRetrieve"] = commaRepresentation(attributesToRetrieve)
      }

      if !attributesToCrop.isEmpty {
        dic["attributesToCrop"] = commaRepresentation(attributesToCrop)
      }

      dic["cropLength"] = "\(cropLength)"

      if !attributesToHighlight.isEmpty {
        dic["attributesToHighlight"] = commaRepresentation(attributesToHighlight)
      }

      if let filters: Filter = self.filters {
        dic["filters"] = "\(filters.attribute):\(filters.value)"
      }

      dic["matches"] = "\(matches)"
      return dic
    }

    private func commaRepresentation(_ array: [String]) -> String {
      array.joined(separator:",")
    }

    /**
     `Filter` instances represent filter used in thr search query.
     */
    public struct Filter: Codable, Equatable {

        // MARK: Properties

        /// Parameter from document to be filtered.
        let attribute: String

        /// Value of the document parameter to be filtered.
        let value: String

    }

}