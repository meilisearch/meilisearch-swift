/**
  Returned Setting object with avoided nil values
 */
public struct SettingResult: Codable, Equatable {
  // MARK: Properties

  /// List of ranking rules for a given `Index`.
  public let rankingRules: [String]

  /// List of searchable attributes for a given `Index`.
  public let searchableAttributes: [String]

  /// List of displayed attributes for a given `Index`.
  public let displayedAttributes: [String]

  /// List of stop-words for a given `Index`.
  public let stopWords: [String]

  /// List of synonyms and its values for a given `Index`.
  public let synonyms: [String: [String]]

  /// Optional distinct attribute set for a given `Index`.
  public let distinctAttribute: String?

  /// List of attributes used for filtering
  public let filterableAttributes: [String]

  /// List of attributes used for sorting
  public let sortableAttributes: [String]
}
