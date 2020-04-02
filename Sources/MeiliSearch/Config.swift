
public struct Config {
    let hostURL: String
    let apiKey: String

    func url(api: String) -> String {
        hostURL + api
    }
}