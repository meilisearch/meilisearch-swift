import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

public struct Movie: Codable, Equatable {
  let id: Int
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
  }
}
