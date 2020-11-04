import Foundation

/**
 `Dump` instances represent the current status of a dump in the server
 */
public struct Dump: Codable, Equatable {

    // MARK: Properties

    /// Current hash from the build.
    public let UID: String

    /// Date when the server was compiled.
    public let status: Status

    enum CodingKeys: String, CodingKey {
        case UID = "uid"
        case status
    }

    public enum Status: Codable, Equatable {

        case inProgress
        case failed
        case done

        public enum CodingError: Error {
            case unknownStatus
        }

        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            let rawStatus = try container.decode(String.self)
            switch rawStatus {
            case "in_progress":
                self = .inProgress
            case "dump_process_failed":
                self = .failed
            case "done":
                self = .done
            default:
                throw CodingError.unknownStatus
            }
        }

        public func encode(to encoder: Encoder) throws { }

     }

 }
