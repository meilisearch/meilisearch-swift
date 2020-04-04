import Foundation

public struct Index: Codable, Equatable {

    let name: String
    let uid: String
    let createdAt: Date?
    let updatedAt: Date?
    let primaryKey: String?
    
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