import Foundation

/**
 Each instance of MeiliSearch has three keys: a master, a private, and a public.
 Each key has a given set of permissions on the API routes.
 */
public struct Key: Codable, Equatable {
  // MARK: Properties

  /// Private key used to access a determined set of API routes.
  public let `private`: String

  /// Public key used to access a determined set of API routes.
  public let `public`: String
}
