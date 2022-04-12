public struct Book: Codable, Equatable {
  let id: Int
  let title: String
  let comment: String?
  let genres: [String]?
  let formatted: FormattedBook?
  let matchesInfo: MatchesInfoBook?

  enum CodingKeys: String, CodingKey {
    case id
    case title
    case comment
    case genres
    case formatted = "_formatted"
    case matchesInfo = "_matchesInfo"
  }

  init(id: Int, title: String, comment: String? = nil, genres: [String] = [], formatted: FormattedBook? = nil, matchesInfo: MatchesInfoBook? = nil) {
    self.id = id
    self.title = title
    self.comment = comment
    self.genres = genres
    self.formatted = formatted
    self.matchesInfo = matchesInfo
  }
}

public struct FormattedBook: Codable, Equatable {
  let id: String
  let title: String
  let comment: String?

  init(id: Int, title: String, comment: String? = nil) {
    self.id = String(id)
    self.title = title
    self.comment = comment
  }
}

public struct MatchesInfoBook: Codable, Equatable {
  let comment: [Info]?
  let title: [Info]?
}

public struct Info: Codable, Equatable {
  let start: Int
  let length: Int
}
