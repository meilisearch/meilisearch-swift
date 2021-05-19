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
            let container: SingleValueDecodingContainer = try decoder.singleValueContainer()
            let rawStatus: String = try container.decode(String.self)
            switch rawStatus {
            case "in_progress":
                self = Status.inProgress
            case "dump_process_failed":
                self = Status.failed
            case "done":
                self = Status.done
            default:
                throw CodingError.unknownStatus
            }
        }

        public func encode(to encoder: Encoder) throws { }

     }

 }
