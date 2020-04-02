import Foundation

public struct Schema: Codable {
    let id: [String]
    let title: [String]
    let description: [String]
    let releaseDate: [String]
    let cover: [String]

    func toJSONString() -> String {
        let jsonData = try! JSONEncoder().encode(self)
        return String(data: jsonData, encoding: .utf8)!
    }
}