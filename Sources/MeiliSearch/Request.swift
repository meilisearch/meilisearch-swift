import Foundation

class Request {

    private let config: Config
    
    init(config: Config) {
        self.config = config
    }

    func get(
        api: String, 
        param: String? = nil, 
        _ completion: @escaping (Result<Data, Error>) -> Void) {

        var urlString: String = config.url(api: api)
        if let param: String = param, !param.isEmpty {
            urlString += param
        }

        let url = URL(string: urlString)!

        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
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

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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
        _ completion: @escaping (Result<Data, Error>) -> Void) {
        
        let urlString: String = config.url(api: api)
        var request = URLRequest(url: URL(string: urlString)!)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
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

}