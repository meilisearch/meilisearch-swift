import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

/**
 A `Config` instance represents the config used by MeiliSearch instance.
 */
public class Config {
  // MARK: Properties

  /// Address for the Meilisearch server.
  let host: String

  /// API key needed for an environment that requires one.
  let apiKey: String?

  /// Custom URL session useful to replace the native network library.
  let session: URLSessionProtocol?

  /// Custom headers provided along with each request.
  let headers: [String: String]

  // MARK: Initializers

  /**
   Obtains a Config instance for the given `host` and optional `apiKey`
   with an optional custom `session` URLSessionProtocol.

   - parameter host:  Address for the Meilisearch server.
   - parameter apiKey:   API key needed for the production environment.
   - parameter session:  A custom produced URLSessionProtocol.
   */
  public init(
    host: String,
    apiKey: String? = nil,
    session: URLSessionProtocol? = URLSession.shared,
    headers: [String: String] = [:]
  ) {
    self.host = host
    self.apiKey = apiKey
    self.session = session
    self.headers = headers
  }

  // MARK: Build URL

  func url(api: String) -> String { host + api }

  // MARK: Validate

  /**
   Validate if the Meilisearch provided host is a well formatted URL.
   */
  func validate() throws -> Config {
    guard let url = URL(string: host) else {
      throw MeiliSearch.Error.hostNotValid
    }
    if url.scheme == nil {
      throw MeiliSearch.Error.hostNotValid
    }
    return self
  }
}
