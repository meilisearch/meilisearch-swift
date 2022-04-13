import Foundation
import JWTKit

internal struct SearchRulesClaim: JWTClaim, Equatable {
  public var value: SearchRulesGroup

  public init(value: SearchRulesGroup) {
    self.value = value
  }
}
