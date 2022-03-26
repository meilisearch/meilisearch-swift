import Foundation
import JWTKit

internal struct ApiKeyClaim: JWTClaim, Equatable {
  /// See `JWTClaim`.
  public var value: String

  /// See `JWTClaim`.
  public init(value: String) {
    self.value = value
  }

  // Checks if the apiKey sent as value is valid to sign the JWT.
  public func verify() throws {
    if self.value.isEmpty || self.value.count < 8 {
      throw JWTError.claimVerificationFailure(name: "apiKeyPrefix", reason: "invalid key sent")
    }
  }
}
