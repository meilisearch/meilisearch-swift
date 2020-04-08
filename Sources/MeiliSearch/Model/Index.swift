import Foundation

/**
 `Index` instances is an entity that gathers a set of documents with its own settings.
 It can be comparable to a table in SQL, or a collection in MongoDB.
 */
public struct Index: Codable, Equatable {

    // MARK: Properties

    /// The index name.
    public let name: String

    /// The index UID.
    public let UID: String

    /// The data when the index was created.
    public let createdAt: Date?

    /// The data when the index was last updated.
    public let updatedAt: Date?

    /// The primary key configured for the index.
    public let primaryKey: String?

    // MARK: Initializers

    init(
        name: String,
        UID: String,
        createdAt: Date? = nil,
        updatedAt: Date? = nil,
        primaryKey: String? = nil) {
        self.name = name
        self.UID = UID
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.primaryKey = primaryKey
    }

    enum CodingKeys: String, CodingKey {
        case name
        case UID = "uid"
        case createdAt
        case updatedAt
        case primaryKey
    }

}
