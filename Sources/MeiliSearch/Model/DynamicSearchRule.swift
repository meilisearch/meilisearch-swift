import Foundation

/**
 A dynamic search rule configured on a Meilisearch instance.
 */
public struct DynamicSearchRule: Codable, Equatable {
  public let uid: String
  public let description: String?
  public let precedence: Int?
  public let active: Bool
  public let conditions: DynamicSearchRuleConditions
  public let actions: [DynamicSearchRuleAction]

  public init(
    uid: String,
    description: String? = nil,
    precedence: Int? = nil,
    active: Bool,
    conditions: DynamicSearchRuleConditions = DynamicSearchRuleConditions(),
    actions: [DynamicSearchRuleAction]
  ) {
    self.uid = uid
    self.description = description
    self.precedence = precedence
    self.active = active
    self.conditions = conditions
    self.actions = actions
  }
}

public struct DynamicSearchRuleConditions: Codable, Equatable {
  public let time: DynamicSearchRuleTimeCondition?
  public let query: DynamicSearchRuleQueryCondition?

  public init(
    time: DynamicSearchRuleTimeCondition? = nil,
    query: DynamicSearchRuleQueryCondition? = nil
  ) {
    self.time = time
    self.query = query
  }
}

public struct DynamicSearchRuleTimeCondition: Codable, Equatable {
  public let start: String?
  public let end: String?

  public init(start: String? = nil, end: String? = nil) {
    self.start = start
    self.end = end
  }
}

public struct DynamicSearchRuleQueryCondition: Codable, Equatable {
  public let isEmpty: Bool?
  public let words: String?

  public init(isEmpty: Bool? = nil, words: String? = nil) {
    self.isEmpty = isEmpty
    self.words = words
  }
}

public struct DynamicSearchRuleAction: Codable, Equatable {
  public let selector: DynamicSearchRuleSelector
  public let action: DynamicSearchRuleActionPayload

  public init(
    selector: DynamicSearchRuleSelector,
    action: DynamicSearchRuleActionPayload
  ) {
    self.selector = selector
    self.action = action
  }
}

public struct DynamicSearchRuleSelector: Codable, Equatable {
  public let indexUid: String?
  public let id: String

  public init(indexUid: String? = nil, id: String) {
    self.indexUid = indexUid
    self.id = id
  }
}

public struct DynamicSearchRuleActionPayload: Codable, Equatable {
  public let type: DynamicSearchRuleActionType
  public let position: Int

  public init(type: DynamicSearchRuleActionType = .pin, position: Int) {
    self.type = type
    self.position = position
  }
}

public enum DynamicSearchRuleActionType: Codable, Equatable, LosslessStringConvertible {
  case pin
  case unknown(String)

  public init(from decoder: Decoder) throws {
    let value = try decoder.singleValueContainer().decode(String.self)
    self.init(rawValue: value)
  }

  internal init(rawValue: String) {
    switch rawValue {
    case "pin":
      self = .pin
    default:
      self = .unknown(rawValue)
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(description)
  }

  public init?(_ description: String) {
    self.init(rawValue: description)
  }

  public var description: String {
    switch self {
    case .pin:
      return "pin"
    case .unknown(let value):
      return value
    }
  }
}
