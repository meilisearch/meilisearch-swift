@testable import MeiliSearch
import XCTest
import JWTKit

class TenantTokensTests: XCTestCase {
  var signer: JWTSigner?
  var rules = SearchRulesGroup([SearchRules("*")])

  @discardableResult
  func setupSigner(key: String? = nil) -> String {
    let signers = JWTSigners()
    let key = key ?? UUID().uuidString
    let signer = JWTSigner.hs256(key: key)

    self.signer = signer
    signers.use(signer)

    return key
  }

  func testGenerateTokenWithApiKeyAndWithoutExpiration() throws {
    let key = setupSigner()

    TenantTokens.generateTenantToken(self.rules, apiKey: key) { result in
      switch result {
      case .success(let jwt):
        XCTAssertNotNil(jwt)

        do {
          if let signer = self.signer {
            let payload = try signer.verify(jwt, as: TokenPayload.self)

            XCTAssertNil(payload.exp)
            XCTAssertEqual(payload.apiKeyPrefix?.value, String(key.prefix(8)))
            XCTAssertEqual(payload.searchRules.value, self.rules)
          }
        } catch {
          XCTFail("Failed to verify/decode generated token.")
        }
      case .failure:
        XCTFail("Failed to generate the JWT token.")
      }
    }
  }

  func testGenerateTokenDoesNotParseWithWrongKey() throws {
    setupSigner()

    TenantTokens.generateTenantToken(self.rules, apiKey: "any-other-key") { result in
      switch result {
      case .success(let jwt):
        XCTAssertNotNil(jwt)

        do {
          _ = try self.signer?.verify(jwt, as: TokenPayload.self)
        } catch let err {
          XCTAssertNotNil(err)
        }
      case .failure:
        XCTFail("Failed to generate the JWT token.")
      }
    }
  }

  func testGenerateTokenWithInvalidApiKey() throws {
    // closure that will handle the assertions for two different comparisons
    let assertionHandler = { (result: Result<String, Error>) in
      switch result {
      case .success:
        XCTFail("The generateTenantToken should be a .failure not a .success")
      case .failure(let err):
        XCTAssertNotNil(err)
      }
    }

    TenantTokens.generateTenantToken(self.rules, apiKey: "", assertionHandler)
    TenantTokens.generateTenantToken(self.rules, apiKey: "small", assertionHandler)
  }

  func testGenerateTokenWithExpiration() throws {
    let key = setupSigner()

    TenantTokens.generateTenantToken(self.rules, apiKey: key, expiresAt: Date.distantFuture) { result in
      switch result {
      case .success(let jwt):
        do {
          if let signer = self.signer {
            let payload = try signer.verify(jwt, as: TokenPayload.self)

            XCTAssertNotNil(payload.exp)
            XCTAssertEqual(payload.exp?.value, Date.distantFuture)
          }
        } catch {
          XCTFail("Failed to verify/decode generated token.")
        }
      case .failure:
        XCTFail("The generateTenantToken should be able to get a token with valid exp")
      }
    }
  }

  func testGenerateTokenWithPastExpiration() throws {
    let key = setupSigner()

    TenantTokens.generateTenantToken(self.rules, apiKey: key, expiresAt: Date.distantPast) { result in
      switch result {
      case .success:
        XCTFail("The generateTenantToken should be a .failure not a .success")
      case .failure(let err):
        XCTAssertNotNil(err)
      }
    }
  }
}
