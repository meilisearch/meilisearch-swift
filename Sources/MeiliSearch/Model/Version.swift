import Foundation

public struct Version: Codable, Equatable {
    public let commitSha: String
    public let buildDate: Date
    public let pkgVersion: String
}
