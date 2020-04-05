import Foundation

public struct Index: Codable, Equatable {

    public let name: String
    public let uid: String
    public let createdAt: Date?
    public let updatedAt: Date?
    public let primaryKey: String?

    init(
        name: String,
        uid: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        primaryKey: String? = nil) {
        self.name = name
        self.uid = uid
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.primaryKey = primaryKey
    }

}
