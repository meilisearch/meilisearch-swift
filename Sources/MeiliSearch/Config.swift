import Foundation

public struct Config {
    let hostURL: String
    let apiKey: String
    internal let session: URLSessionProtocol

    func url(api: String) -> String {
        hostURL + api
    }

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

}
