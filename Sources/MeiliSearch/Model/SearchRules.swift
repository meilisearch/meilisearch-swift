import Foundation

public struct SearchRules: Codable, Equatable {
  var index: String = "*"
  var filter: String?

  init(_ index: String, filter: String? = nil) {
    self.index = index
    self.filter = filter
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    var dict = [String: [String: String?]]()

    guard let filter = self.filter, !filter.isEmpty else {
      try container.encode([index])

      return
    }

    dict[index] = ["filter": self.filter]

    try container.encode(dict)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let indexes = try? container.decode([String].self), !indexes.isEmpty, let index = indexes.first {
      self.index = index

      return
    }

    if let dict = try? container.decode([String: [String: String]].self) {
      if let key = dict.keys.first {
        self.index = key

        if let value = dict[key] {
          self.filter = value["filter"]
        }
      }

      return
    }

    throw DecodingError.typeMismatch(
      SearchRules.self,
      DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SearchRules")
    )
  }

  public func getFilterDict() -> [String: String?]? {
    guard let filter = self.filter, !filter.isEmpty else {
      return [String: String?]()
    }

    return ["filter": self.filter]
  }
}
