public struct NestedBook: Codable, Equatable {
  let id: Int
  let title: String
  let info: InfoNested
  let genres: [String]?
  let formatted: FormattedNestedBook?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case info
    case genres
    case formatted = "_formatted"
  }

  init(id: Int, title: String, info: InfoNested, genres: [String] = [], formatted: FormattedNestedBook? = nil) {
    self.id = id
    self.title = title
    self.info = info
    self.genres = genres
    self.formatted = formatted
  }
}

public struct InfoNested: Codable, Equatable {
  let comment: String
  let reviewNb: Int
}

public struct FormattedNestedBook: Codable, Equatable {
  let id: String
  let title: String
  let info: InfoNested
}
