import Foundation

/**
 A `Config` instance represents the default config used by MeiliSearchClient instance.
 */
public struct Config {

    // MARK: Properties

    /// Address for the MeiliSearch server.
    let hostURL: String

    /// API key needed for the production environment.
    let apiKey: String

    internal let session: URLSessionProtocol

    // MARK: Initializers

    /**
     Obtains a Config instance for the given `hostURL` and optional apiKey.

     - parameter hostURL: Address for the MeiliSearch server.
     - parameter apiKey:  API key needed for the production environment.
     */
    public init(hostURL: String, apiKey: String = "") {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = URLSession.shared
    }

    internal init(hostURL: String,
         apiKey: String = "",
         session: URLSessionProtocol = URLSession.shared) {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = session
    }

    func url(api: String) -> String {
        hostURL + api
    }

}
