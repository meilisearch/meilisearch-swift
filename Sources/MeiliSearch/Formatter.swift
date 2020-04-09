import Foundation

extension Formatter {
    static let iso8601: DateFormatter = {
        let formatter: DateFormatter = DateFormatter()
          formatter.calendar = Calendar(identifier: .iso8601)
          formatter.locale = Locale(identifier: "en_US_POSIX")
          formatter.timeZone = TimeZone(secondsFromGMT: 0)
          formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSXXXXX"
        return formatter
    }()
}

func queryURL(api: String, _ values: [String: String]) -> String {
    if values.isEmpty {
        return api
    }
    guard var components: URLComponents = URLComponents(string: api) else {
        fatalError()
    }
    components.queryItems = values.map { (name: String, value: String) in
        URLQueryItem(name: name, value: value)
    }
    if let string: String = components.string {
        return string
    }
    fatalError()
}
