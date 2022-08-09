import Foundation

/**
 `TasksResults` is a wrapper used in the tasks routes to handle the returned data.
 */

public struct TasksResults: Codable, Equatable {
  /// Results list containing objects of `Task`.
  public let results: [Task]
  /// Integer value used to retrieve the next batch of tasks.
  public let next: Int?
  /// Integer value representing the first `uid` of the first task returned.
  public let from: Int?
  /// Max number of records to be returned in one request.
  public let limit: Int
}
