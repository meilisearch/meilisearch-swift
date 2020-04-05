import Foundation

public struct AllStats: Codable, Equatable {
    public let databaseSize: Int
    public let lastUpdate: Date?
    public let indexes: [String: Stat]
}

public struct Stat: Codable, Equatable {
    public let numberOfDocuments: Int
    public let isIndexing: Bool
    public let fieldsFrequency: [String: Int]
}
