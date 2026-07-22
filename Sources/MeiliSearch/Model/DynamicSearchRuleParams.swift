import Foundation

public struct DynamicSearchRulesQuery: Codable, Equatable {
  public let offset: Int?
  public let limit: Int?
  public let filter: DynamicSearchRulesFilter?

  public init(
    offset: Int? = nil,
    limit: Int? = nil,
    filter: DynamicSearchRulesFilter? = nil
  ) {
    self.offset = offset
    self.limit = limit
    self.filter = filter
  }
}

public struct DynamicSearchRulesFilter: Codable, Equatable {
  public let query: String?
  public let active: Bool?

  public init(query: String? = nil, active: Bool? = nil) {
    self.query = query
    self.active = active
  }
}

public struct DynamicSearchRuleParams: Codable, Equatable {
  public let description: String?
  public let precedence: Int?
  public let active: Bool?
  public let conditions: DynamicSearchRuleConditions?
  public let actions: [DynamicSearchRuleAction]?

  public init(
    description: String? = nil,
    precedence: Int? = nil,
    active: Bool? = nil,
    conditions: DynamicSearchRuleConditions? = nil,
    actions: [DynamicSearchRuleAction]? = nil
  ) {
    self.description = description
    self.precedence = precedence
    self.active = active
    self.conditions = conditions
    self.actions = actions
  }
}
