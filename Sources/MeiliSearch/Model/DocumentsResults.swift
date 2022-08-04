import Foundation

/**
 `DocumentsResults` is a wrapper used in the indexes routes to handle the returned data.
 */

public struct DocumentsResults<T: Decodable & Encodable & Equatable>: Codable, Equatable {
  public let results: [T]
  public let offset: Int
  public let limit: Int
  public let total: Int
}
