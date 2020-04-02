
import Foundation

public class Index: Codable {

    let name: String
    let uid: String
    let createdAt: Date?
    let updatedAt: Date?
    
    init (name: String, uid: String, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.name = name
        self.uid = uid
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

}