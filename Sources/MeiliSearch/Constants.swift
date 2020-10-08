import Foundation

struct Constants {

    static let customJSONDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .formatted(Formatter.iso8601)
        return decoder
    }()
}
