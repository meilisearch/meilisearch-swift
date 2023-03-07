import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

internal struct PackageVersion {
  /// This is the current version of the meilisearch-swift package
  private static let current = "0.15.0"

  /**
   Retrieves the current version of the MeiliSearch Swift package and formats accordingly.

   - returns: String containing the qualified version of this package eg. `Meilisearch Swift (v1.0.0)`
   */
  static func qualifiedVersion(_ rawVersion: String? = nil) -> String {
    "Meilisearch Swift (v\(rawVersion ?? self.current))"
  }
}
