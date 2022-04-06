import Foundation
import JWTKit

internal struct TokenPayload: JWTPayload, Equatable {
  /// The "exp" (expiration time) claim identifies the expiration time on
  /// or after which the JWT MUST NOT be accepted for processing.
  var exp: ExpirationClaim?

  /// The "searchRules" claim contains the rules to be enforced at
  /// search time for all or specific accessible indexes for the signing API Key.
  var searchRules: SearchRulesClaim

  /// The "apiKeyPrefix" claim contains the first 8 characters of the
  /// Meilisearch API key that generates and signs the Tenant Token.
  var apiKeyPrefix: ApiKeyPrefixClaim?

  func verify(using signer: JWTSigner) throws {
    try self.exp?.verifyNotExpired()
    try self.apiKeyPrefix?.verify()
  }
}
