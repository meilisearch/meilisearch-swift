import Foundation

public protocol URLSessionProtocol { 
    typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void
    func execute(
        with request: URLRequest, 
        completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol
}

public protocol URLSessionDataTaskProtocol { 
    func resume()
}

final class Request {

    private let config: Config
    private let session: URLSessionProtocol
    
    init(config: Config) {
        self.config = config
        self.session = config.session
    }

    func get(
        api: String, 
        param: String? = nil, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        var urlString: String = config.url(api: api)
        if let param: String = param, !param.isEmpty {
            urlString += param
        }

        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "GET"

        let task = session.execute(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { 
                return
            }
            completion(.success(data))
        }

        task.resume()
    }

    func post(
        api: String, 
        body: Data, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        let urlString: String = config.url(api: api)
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "POST"
        request.httpBody = body

        let task = session.execute(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { 
                return
            }
            completion(.success(data))
        }

        task.resume()

    }

    func put(
        api: String,
        body: Data, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        let urlString: String = config.url(api: api)
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "PUT"
        request.httpBody = body

        let task = session.execute(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let data = data else { 
                return
            }
            completion(.success(data))
        }

        task.resume()

    }

     func delete(
        api: String,
        _ completion: @escaping (Result<Data?, Error>) -> Void) {
        
        let urlString: String = config.url(api: api)
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "DELETE"

        let task = session.execute(with: request) { (data, response, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(data))
        }

        task.resume()

    }

}

extension URLSession: URLSessionProtocol {
    public func execute(
        with request: URLRequest, 
        completionHandler: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        self.dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}