import Foundation

/**
 A `Config` instance represents the default config used by MeiliSearch instance.
 */
public class Config {

    // MARK: Constants

    private static let localhost: String = "http://localhost:7700"

    // MARK: Static

    ///Deafault configuration for the default MeiliSearch host, do not use this in
    ///production since it does not contains the apiKey.
    public static let `default`: Config = Config(hostURL: localhost)

    /// Default config instance set up to use localhost and port 7700.
    public static func `default`(
        apiKey: String = "",
        session: URLSessionProtocol = URLSession.shared) -> Config {
        Config(hostURL: localhost, apiKey: apiKey, session: session)
    }

    // MARK: Properties

    /// Address for the MeiliSearch server.
    let hostURL: String?

    /// API key needed for the production environment.
    let apiKey: String

    /// Custom URL session useful to replace the native network library.
    var session: URLSessionProtocol

    // MARK: Initializers

    /**
     Obtains a Config instance for the given `hostURL` and optional apiKey.

     - parameter hostURL: Address for the MeiliSearch server.
     - parameter apiKey:  API key needed for the production environment.
     */
    public init(hostURL: String? = nil, apiKey: String = "") {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = URLSession.shared
    }

    /**
     Obtains a Config instance for the given `hostURL` and optional `apiKey`
     with a custom `session` URLSessionProtocol.

     - parameter hostURL: Address for the MeiliSearch server.
     - parameter apiKey:  API key needed for the production environment.
     - parameter session:  A custom produced URLSessionProtocol.
    */
    public init(
        hostURL: String?,
        apiKey: String = "",
        session: URLSessionProtocol) {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = session
    }

    // MARK: Build

    func url(api: String) -> String {
        guard let hostURL = self.hostURL else {
            return api
        }
        return hostURL + api
    }

    // MARK: Validate

    /**
     Validate if the MeiliSearch server can be connected.
     */
    func validate(_ request: Request) throws -> Config {

        guard let hostURL: String = self.hostURL else {
            return self
        }

        guard let _ = URL(string: hostURL) else {
            throw MeiliSearch.Error.hostNotValid
        }

        let success: Bool = autoreleasepool {
            let semaphore = DispatchSemaphore(value: 0)
            var success: Bool = false
            request.get(api: "") { result in
                switch result {
                case .success:
                    success = true
                case .failure:
                    success = false
                }
                semaphore.signal()
            }
            semaphore.wait()
            return success
        }

        if !success {
            throw MeiliSearch.Error.serverNotFound
        }
        return self

    }

}
