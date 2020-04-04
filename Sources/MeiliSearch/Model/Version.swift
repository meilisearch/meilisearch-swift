import Foundation

public struct Version: Codable, Equatable {
    let commitSha: String
    let buildDate: Date
    let pkgVersion: String
}