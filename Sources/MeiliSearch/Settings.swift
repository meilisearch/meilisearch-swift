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

    // MARK: Ranking

    func getRankingRules(
        _ UID: String,
        _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/ranking-rules") { result in

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

    func updateRankingRules(
        _ UID: String,
        _ rankingRules: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: rankingRules, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/ranking-rules", data) { result in

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

    func resetRankingRules(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/ranking-rules") { result in

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

    // MARK: Distinct attribute

    func getDistinctAttribute(
        _ UID: String,
        _ completion: @escaping (Result<String, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/distinct-attribute") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                let distinctAttribute: String = String(
                  decoding: data, as: UTF8.self)

                completion(.success(distinctAttribute))

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func updateDistinctAttribute(
        _ UID: String,
        _ distinctAttribute: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        guard let data: Data = distinctAttribute.data(using: .ascii) else {
            completion(.failure(MeiliSearch.Error.invalidJSON))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/distinct-attribute", data) { result in

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

    func resetDistinctAttribute(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/distinct-attribute") { result in

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

    // MARK: Searchable attributes

    func getSearchableAttributes(
        _ UID: String,
        _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/searchable-attributes") { result in

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

    func updateSearchableAttributes(
        _ UID: String,
        _ searchableAttributes: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: searchableAttributes, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/searchable-attributes", data) { result in

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

    func resetSearchableAttributes(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/searchable-attributes") { result in

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

    // MARK: Displayed attributes

    func getDisplayedAttributes(
        _ UID: String,
        _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/displayed-attributes") { result in

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

    func updateDisplayedAttributes(
        _ UID: String,
        _ displayedAttributes: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: displayedAttributes, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/displayed-attributes", data) { result in

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

    func resetDisplayedAttributes(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/displayed-attributes") { result in

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

    // MARK: Accept New Fields

    func getAcceptNewFields(
        _ UID: String,
        _ completion: @escaping (Result<Bool, Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/accept-new-fields") { result in

            switch result {
            case .success(let data):

                guard let data: Data = data else {
                    completion(.failure(MeiliSearch.Error.dataNotFound))
                    return
                }

                let acceptNewFields: String = String(decoding: data, as: UTF8.self)

                completion(.success(acceptNewFields == "true"))

            case .failure(let error):
                completion(.failure(error))
            }

        }

    }

    func updateAcceptNewFields(
        _ UID: String,
        _ acceptNewFields: Bool,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let acceptNewFieldsString: String = acceptNewFields ? "true" : "false"
        guard let data: Data = acceptNewFieldsString.data(using: .ascii) else {
            completion(.failure(MeiliSearch.Error.invalidJSON))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/accept-new-fields", data) { result in

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

    // MARK: Attributes for faceting

    func getAttributesForFaceting(
        _ UID: String,
        _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {

        self.request.get(api: "/indexes/\(UID)/settings/attributes-for-faceting") { result in

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

    func updateAttributesForFaceting(
        _ UID: String,
        _ attributes: [String],
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        let data: Data
        do {
          data = try JSONSerialization.data(withJSONObject: attributes, options: [])
        } catch {
            completion(.failure(error))
            return
        }

        self.request.post(api: "/indexes/\(UID)/settings/attributes-for-faceting", data) { result in

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

    func resetAttributesForFaceting(
        _ UID: String,
        _ completion: @escaping (Result<Update, Swift.Error>) -> Void) {

        self.request.delete(api: "/indexes/\(UID)/settings/attributes-for-faceting") { result in

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
