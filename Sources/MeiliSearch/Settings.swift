import Foundation

/**
 Settings is a list of all the customization possible for an index.
 */
struct Settings {

    // MARK: Properties

    let request: Request

    // MARK: Initializers

    init (_ request: Request) {
        self.request = request
    }

    // MARK: All Settings

    func get(
        _ UID: String,
        _ completion: @escaping (Result<Setting, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let settings: Setting = try decoder.decode(Setting.self, from: data)
                    completion(.success(settings))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func update(
        _ UID: String,
        _ setting: Setting,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
            data = try JSONEncoder().encode(setting)
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings", data) { result in

            switch result {
            case .success(let data):

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func reset(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    // MARK: Synonyms

    func getSynonyms(
        _ UID: String,
        _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/synonyms") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let dictionary: [String: [String]] = try JSONSerialization
                        .jsonObject(with: data, options: []) as! [String: [String]]
                    completion(.success(dictionary))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func updateSynonyms(
        _ UID: String,
        _ synonyms: [String: [String]],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: synonyms, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/synonyms", data) { result in

            switch result {
            case .success(let data):

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func resetSynonyms(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/synonyms") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    // MARK: Stop Words

    func getStopWords(
        _ UID: String,
        _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/stop-words") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let dictionary: [String] = try JSONSerialization
                        .jsonObject(with: data, options: []) as! [String]
                    completion(.success(dictionary))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func updateStopWords(
        _ UID: String,
        _ synonyms: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: synonyms, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/stop-words", data) { result in

            switch result {
            case .success(let data):

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func resetStopWords(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/stop-words") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                do {
                    let decoder: JSONDecoder = JSONDecoder()
                    let update: Update = try decoder.decode(Update.self, from: data)
                    completion(.success(update))
                } catch {
                    completion(.failure(error))
                }

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

}
