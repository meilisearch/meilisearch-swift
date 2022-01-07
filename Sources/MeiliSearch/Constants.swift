import Foundation

struct Constants {
  static let customJSONDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = JSONDecoder.DateDecodingStrategy.formatted(Formatter.iso8601)
    return decoder
  }()

  static let customJSONEecoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = JSONEncoder.DateEncodingStrategy.formatted(Formatter.iso8601)
    return encoder
  }()
}
