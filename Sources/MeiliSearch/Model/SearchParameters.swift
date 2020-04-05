import Foundation

public struct SearchParameters: Codable, Equatable {
    let query: String
    let offset: Int
    let limit: Int
    let attributesToRetrieve: [String]?
    let attributesToCrop: [String]
    let cropLength: Int
    let attributesToHighlight: [String]
    let filters: Filter?
    let matches: Bool

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
      dic["d"] = query
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