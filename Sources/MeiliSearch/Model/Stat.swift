import Foundation

public struct AllStats: Codable, Equatable {
  let databaseSize: Int
  let lastUpdate: Date?
  let indexes: [String: Stat]
}

public struct Stat: Codable, Equatable {
  let numberOfDocuments: Int
  let isIndexing: Bool
  let fieldsFrequency: [String: Int]
}
