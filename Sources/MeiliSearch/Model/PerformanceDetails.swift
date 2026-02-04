import Foundation

/**
 `PerformanceDetails` represents the performance trace returned by Meilisearch
 when `showPerformanceDetails` is set to `true` in search requests.

 Note: The internal structure of performance details is subject to change
 in future Meilisearch versions. This struct provides raw access to the data
 without imposing a specific schema.

 Available from Meilisearch v1.35.0.
 */
public struct PerformanceDetails: Codable, Equatable {
  /// The raw performance details data.
  /// The structure may vary between Meilisearch versions.
  public let rawValue: [String: PerformanceValue]

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    self.rawValue = try container.decode([String: PerformanceValue].self)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(rawValue)
  }
}

/**
 A recursive enum type to represent arbitrary JSON values in performance details.
 */
public enum PerformanceValue: Codable, Equatable {
  case string(String)
  case int(Int)
  case double(Double)
  case bool(Bool)
  case object([String: PerformanceValue])
  case array([PerformanceValue])
  case null

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if container.decodeNil() {
      self = .null
    } else if let value = try? container.decode(Bool.self) {
      self = .bool(value)
    } else if let value = try? container.decode(Int.self) {
      self = .int(value)
    } else if let value = try? container.decode(Double.self) {
      self = .double(value)
    } else if let value = try? container.decode(String.self) {
      self = .string(value)
    } else if let value = try? container.decode([String: PerformanceValue].self) {
      self = .object(value)
    } else if let value = try? container.decode([PerformanceValue].self) {
      self = .array(value)
    } else {
      throw DecodingError.typeMismatch(
        PerformanceValue.self,
        DecodingError.Context(
          codingPath: decoder.codingPath,
          debugDescription: "Unable to decode PerformanceValue"
        )
      )
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()

    switch self {
    case .string(let value):
      try container.encode(value)
    case .int(let value):
      try container.encode(value)
    case .double(let value):
      try container.encode(value)
    case .bool(let value):
      try container.encode(value)
    case .object(let value):
      try container.encode(value)
    case .array(let value):
      try container.encode(value)
    case .null:
      try container.encodeNil()
    }
  }
}
