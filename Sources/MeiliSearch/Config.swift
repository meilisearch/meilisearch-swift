import Foundation

/**
 A `Config` instance represents the config used by MeiliSearch instance.
 */
public class Config {

    // MARK: Properties

    /// Address for the MeiliSearch server.
    let hostURL: String

    /// API key needed for an environment that requires one.
    let apiKey: String?

    /// Custom URL session useful to replace the native network library.
    var session: URLSessionProtocol?

    // MARK: Initializers


    /**
     Obtains a Config instance for the given `hostURL` and optional `apiKey`
     with an optional custom `session` URLSessionProtocol.

     - parameter hostURL:  Address for the MeiliSearch server.
     - parameter apiKey:   API key needed for the production environment.
     - parameter session:  A custom produced URLSessionProtocol.
    */
    public init(
        hostURL: String,
        apiKey: String? = nil,
        session: URLSessionProtocol? = URLSession.shared) {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: Build URL

    func url(api: String) -> String {
        return hostURL + api
    }

    // MARK: Validate

    /**
     Validate if the MeiliSearch provided host is a well formatted URL.
     */
    func validate() throws -> Config {
        guard URL(string: hostURL) != nil else {
            throw MeiliSearch.Error.hostNotValid
        }
       return self
    }

}
