import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/// A value that can be decoded as either an integer (raw bytes) or a string
/// (human-readable size such as `"2.3 MiB"`), depending on the `sizeFormat`
/// query parameter used when fetching stats.
public enum SizeValue: Codable, Equatable {
  case integer(Int)
  case string(String)

  public init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()
    if let int = try? container.decode(Int.self) {
      self = .integer(int)
    } else {
      self = .string(try container.decode(String.self))
    }
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case .integer(let v): try container.encode(v)
    case .string(let v): try container.encode(v)
    }
  }
}

/**
 `AllStats` instances represent stat of all Indexes.
 */
public struct AllStats: Codable, Equatable {
  // MARK: Properties

  /// Size of the whole database. Returns bytes when `sizeFormat` is `raw` (default),
  /// or a human-readable string such as `"2.3 MiB"` when `sizeFormat` is `human`.
  public let databaseSize: SizeValue

  /// Date when the server was last updated.
  public let lastUpdate: Date?

  /// Dictionary of all Indexes containing the stat for each Index.
  public let indexes: [String: Stat]
}

/**
 `Stat` instances represent stat of a specific Index.
 */
public struct Stat: Codable, Equatable {
  // MARK: Properties

  /// Number of documents in the given index.
  public let numberOfDocuments: Int

  /// Returns if the Index is currently being indexed.
  public let isIndexing: Bool

  /// Usage frequency for each Index field.
  public let fieldDistribution: [String: Int]

  /// Internal database sizes for the index.
  /// Present only when `showInternalDatabaseSizes` is `true`.
  /// **Note:** The keys in this dictionary are subject to change.
  public let internalDatabaseSizes: [String: SizeValue]?
}
