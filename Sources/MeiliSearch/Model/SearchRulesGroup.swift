import Foundation

public struct SearchRulesGroup: Codable, Equatable {
  var members: [SearchRules] = []

  init(_ members: [SearchRules]) {
    precondition(members.count > 0, "One or more SearchRules() are required")

    self.members = members
  }

  init(_ searchRules: SearchRules) {
    self.init([searchRules])
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    var dict = [String: [String: String?]]()

    for rule in self.members {
      if let filter = rule.getFilterDict() {
        dict[rule.index] = filter
      }
    }

    try container.encode(dict)
  }

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let list = try? container.decode([String].self) {
      for item in list {
        self.members.append(SearchRules(item))
      }

      return
    }

    if let list = try? container.decode([String: [String: String]].self) {
      for (index, value) in list {
        self.members.append(SearchRules(index, filter: value["filter"] ?? nil))
      }

      return
    }

    throw DecodingError.typeMismatch(
      SearchRules.self,
      DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for SearchRules")
    )
  }
}
