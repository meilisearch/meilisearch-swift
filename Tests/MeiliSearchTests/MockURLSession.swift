@testable import MeiliSearch
import Foundation

class MockURLSession: URLSessionProtocol {

    private(set) var nextDataTask = MockURLSessionDataTask()
    private(set) var nextData: Data?
    private(set) var nextError: Error?
    private(set) var nextCode: Int = -1
    
    private(set) var lastURL: URL?
    
    func successHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: nextCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }

    func failureHttpURLResponse(request: URLRequest) -> URLResponse {
        return HTTPURLResponse(url: request.url!, statusCode: nextCode, httpVersion: "HTTP/1.1", headerFields: nil)!
    }
    
    func execute(with request: URLRequest, completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = request.url

        if nextError == nil {
            completionHandler(nextData, successHttpURLResponse(request: request), nextError)
        } else {
            completionHandler(nextData, failureHttpURLResponse(request: request), nextError)
        }
        
        return nextDataTask
    }

    func pushData(_ string: String) {
        self.nextData = string.data(using: .utf8)!
        self.nextError = nil
        self.nextCode = 200
    }

    func pushEmpty(code: Int) {
        self.nextData = nil
        self.nextError = nil
        self.nextCode = code
    }

    func pushError(_ string: String?, _ error: Error, code: Int) {
        self.nextData = string?.data(using: .utf8)
        self.nextError = error
        self.nextCode = code
    }

}

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    private (set) var resumeWasCalled = false
    
    func resume() {
        resumeWasCalled = true
    }
}