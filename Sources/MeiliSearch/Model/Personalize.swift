import Foundation

/**
 `Personalize` settings for a search request.

 Experimental: personalized search must be enabled on the Meilisearch instance for this parameter
 to have an effect. See [personalized search](https://www.meilisearch.com/docs/capabilities/personalization/getting_started/personalized_search).
 */
public struct Personalize: Codable, Equatable {
  // MARK: Properties

  /// A string describing the user (e.g. preferences, behavior), used to tailor
  /// search results to that profile.
  public let userContext: String

  public init(userContext: String) {
    self.userContext = userContext
  }
}
