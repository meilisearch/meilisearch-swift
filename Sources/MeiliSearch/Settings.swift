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
    _ uid: String,
    _ completion: @escaping (Result<SettingResult, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let settings: SettingResult = try Constants.customJSONDecoder.decode(SettingResult.self, from: data)
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
    _ uid: String,
    _ setting: Setting,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(setting)
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // can this be refactor
  func reset(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
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
    _ uid: String,
    _ completion: @escaping (Result<[String: [String]], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/synonyms") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let dictionary: [String: [String]] = try Constants.customJSONDecoder.decode([String: [String]].self, from: data)
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
    _ uid: String,
    _ synonyms: [String: [String]]? = [:],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(synonyms)
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/synonyms", data) { result in
      switch result {
      case .success(let data):
        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetSynonyms(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/synonyms") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
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
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/stop-words") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateStopWords(
    _ uid: String,
    _ stopWords: [String]? = [],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONEncoder().encode(stopWords)
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/stop-words", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetStopWords(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/stop-words") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
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
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/ranking-rules") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateRankingRules(
    _ uid: String,
    _ rankingRules: [String],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: rankingRules, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/ranking-rules", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetRankingRules(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/ranking-rules") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Distinct attribute

  struct DistinctAttributePayload: Codable, Equatable {
    /// Distinct attribute key
    public let distinctAttribute: String
  }

  func getDistinctAttribute(
    _ uid: String,
    _ completion: @escaping (Result<String?, Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/distinct-attribute") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let value: String? = try Constants.customJSONDecoder.decode(String?.self, from: data)
          completion(.success(value))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateDistinctAttribute(
    _ uid: String,
    _ distinctAttribute: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try Constants.customJSONEecoder.encode(DistinctAttributePayload(distinctAttribute: distinctAttribute))
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetDistinctAttribute(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/distinct-attribute") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
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
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/searchable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateSearchableAttributes(
    _ uid: String,
    _ searchableAttributes: [String],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: searchableAttributes, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/searchable-attributes", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetSearchableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/searchable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
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
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/displayed-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateDisplayedAttributes(
    _ uid: String,
    _ displayedAttributes: [String],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: displayedAttributes, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/displayed-attributes", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetDisplayedAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/displayed-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Filterable Attributes

  func getFilterableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/filterable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateFilterableAttributes(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: attributes, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/filterable-attributes", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetFilterableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/filterable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  // MARK: Sortable Attributes

  func getSortableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<[String], Swift.Error>) -> Void) {
    self.request.get(api: "/indexes/\(uid)/settings/sortable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let array: [String] = try Constants.customJSONDecoder.decode([String].self, from: data)
          completion(.success(array))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateSortableAttributes(
    _ uid: String,
    _ attributes: [String],
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    let data: Data
    do {
      data = try JSONSerialization.data(withJSONObject: attributes, options: [])
    } catch {
      completion(.failure(error))
      return
    }

    self.request.post(api: "/indexes/\(uid)/settings/sortable-attributes", data) { result in
      switch result {
      case .success(let data):

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func resetSortableAttributes(
    _ uid: String,
    _ completion: @escaping (Result<TaskResult, Swift.Error>) -> Void) {

    self.request.delete(api: "/indexes/\(uid)/settings/sortable-attributes") { result in
      switch result {
      case .success(let data):

        guard let data: Data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }

        do {
          let task: TaskResult = try Constants.customJSONDecoder.decode(TaskResult.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }

      case .failure(let error):
        completion(.failure(error))
      }
    }
  }
}
