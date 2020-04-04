import Foundation

public struct Config {
    let hostURL: String
    let apiKey: String
    let session: URLSessionProtocol

    func url(api: String) -> String {
        hostURL + api
    }

    init(hostURL: String,
         apiKey: String = "",
         session: URLSessionProtocol = URLSession.shared) {
        self.hostURL = hostURL
        self.apiKey = apiKey
        self.session = session
    }

}