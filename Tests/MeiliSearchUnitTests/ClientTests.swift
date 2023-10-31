@testable import MeiliSearch
import XCTest

class ClientTests: XCTestCase {
  private let session = MockURLSession()
  private let validHost = "http://localhost:7700"
  private let key = "masterKey"

  func testValidHostURL() {
    session.pushEmpty(code: 200)
    XCTAssertNotNil(try? MeiliSearch(host: self.validHost, apiKey: "masterKey", session: session))
  }

  func testWrongHostURL() {
    XCTAssertThrowsError(try MeiliSearch(host: "1234")) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  func testNotValidHostURL() {
    XCTAssertThrowsError(try MeiliSearch(host: "Not valid host")) { error in
      XCTAssertEqual(error as! MeiliSearch.Error, MeiliSearch.Error.hostNotValid)
    }
  }

  private func optionalDataResponseHandler(result: Result<Data?, Error>) {
    switch result {
    case .success:
      let headers = self.session.nextDataTask.request?.allHTTPHeaderFields ?? [:]

      XCTAssertEqual(headers["User-Agent"], PackageVersion.qualifiedVersion())
    case .failure:
      XCTFail("Must contain a header with PackageVersion.qualifiedVersion value.")
    }
  }

  private func requiredDataResponseHandler(result: Result<Data, Error>) {
    switch result {
    case .success:
      let headers = self.session.nextDataTask.request?.allHTTPHeaderFields ?? [:]

      XCTAssertEqual(headers["User-Agent"], PackageVersion.qualifiedVersion())
    case .failure:
      XCTFail("Must contain a header with PackageVersion.qualifiedVersion value.")
    }
  }

  func testGETHeaders() {
    self.session.pushEmpty(code: 200)

    let config = Config(host: self.validHost, apiKey: self.key, session: self.session)
    let req = Request(config)

    req.get(api: "/", optionalDataResponseHandler)
  }

  func testDELETEHeaders() {
    self.session.pushEmpty(code: 200)

    let config = Config(host: self.validHost, apiKey: self.key, session: self.session)
    let req = Request(config)

    req.delete(api: "/", optionalDataResponseHandler)
  }

  func testPOSTHeaders() {
    session.pushData("{\"uid\": 0}")

    let config = Config(host: self.validHost, apiKey: self.key, session: self.session)
    let req = Request(config)

    req.post(api: "/", "{}".data(using: .utf8) ?? Data(), requiredDataResponseHandler)
  }

  func testPATCHHeaders() {
    session.pushData("{\"uid\": 0}")

    let config = Config(host: self.validHost, apiKey: self.key, session: self.session)
    let req = Request(config)

    req.patch(api: "/", "{}".data(using: .utf8) ?? Data(), requiredDataResponseHandler)
  }

  func testPUTHeaders() {
    session.pushData("{\"uid\": 0}")

    let config = Config(host: self.validHost, apiKey: self.key, session: self.session)
    let req = Request(config)

    req.put(api: "/", "{}".data(using: .utf8) ?? Data(), requiredDataResponseHandler)
  }
}
