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

  static func resultDecoder<T: Decodable>(data: Data?) throws -> Result<T, Swift.Error> {
    guard let data: Data = data else {
      return .failure(MeiliSearch.Error.dataNotFound)
    }
    do {
      let task: T = try Constants.customJSONDecoder.decode(
        T.self,
        from: data)
      return .success(task)
    } catch {
      return .failure(error)
    }
  }

}
