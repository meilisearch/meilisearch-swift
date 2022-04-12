import Foundation
import JWTKit

/// Struct used to generate tenant tokens
internal struct TenantTokens {
  /**
   Generate tenant tokens with a particular set of options, and use this token to authorize search requests.

   - [docs.meilisearch.com](https://docs.meilisearch.com/learn/security/tenant_tokens.html)
   */
  static func generateTenantToken(
    _ searchRules: SearchRulesGroup,
    apiKey: String = "",
    expiresAt: Date? = nil,
    _ completion: @escaping (Result<String, Swift.Error>) -> Void
  ) {
    let signers = JWTSigners()
    signers.use(.hs256(key: apiKey))

    do {
      let payload = try createTokenPayload(
        searchRules: searchRules,
        apiKey: apiKey,
        expiresAt: expiresAt
      )

      let jwt = try signers.sign(payload)

      completion(.success(jwt))
    } catch let error {
      completion(.failure(error))
    }
  }

  private static func createTokenPayload(
    searchRules: SearchRulesGroup,
    apiKey: String,
    expiresAt: Date?
  ) throws -> TokenPayload {
    guard !apiKey.isEmpty else { throw JWTError.signatureVerifictionFailed }

    var payload = TokenPayload(
      searchRules: SearchRulesClaim(value: searchRules),
      apiKeyPrefix: ApiKeyPrefixClaim(value: String(apiKey.prefix(8)))
    )

    if let exp = expiresAt {
      payload.exp = ExpirationClaim(value: exp)
    }

    try payload.verify(using: .hs256(key: apiKey))

    return payload
  }
}
