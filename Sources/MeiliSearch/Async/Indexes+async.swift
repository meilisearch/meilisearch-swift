import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Indexes {
  /**
   Search in the index.
   
   - Parameter searchParameters: Options on search.
   - Throws: Error if a failure occurred.
   - Returns: On completion if the request was successful a `Searchable<T>` instance is returned containing the values.
   */
  public func search<T: Codable & Equatable>(_ searchParameters: SearchParameters) async throws -> Searchable<T> {
    try await withCheckedThrowingContinuation { continuation in
      self.search.search(self.uid, searchParameters) { result in
        continuation.resume(with: result)
      }
    }
  }
}
