import Foundation

public struct SearchParameters: Codable, Equatable {
    public let query: String
    public let offset: Int
    public let limit: Int
    public let attributesToRetrieve: [String]?
    public let attributesToCrop: [String]
    public let cropLength: Int
    public let attributesToHighlight: [String]
    public let filters: Filter?
    public let matches: Bool

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

    public struct Filter: Codable, Equatable {
        let attribute: String
        let value: String
    }

}