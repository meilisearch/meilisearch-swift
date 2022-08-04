import Foundation

/**
 `IndexesResults` is a wrapper used in the indexes routes to handle the returned data.
 */

public struct TasksResults: Codable, Equatable {
  public let results: [Task]
  public let next: Int?
  public let from: Int?
  public let limit: Int
}
