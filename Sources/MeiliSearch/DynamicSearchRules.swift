import Foundation
#if canImport(FoundationNetworking)
  import FoundationNetworking
#endif

struct DynamicSearchRules {
  let request: Request

  init(_ request: Request) {
    self.request = request
  }

  func list(
    params: DynamicSearchRulesQuery?,
    _ completion: @escaping (Result<DynamicSearchRulesResults, Swift.Error>) -> Void
  ) {
    let data: Data
    do {
      data = try Constants.customJSONEecoder.encode(params ?? DynamicSearchRulesQuery())
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    request.post(api: "/dynamic-search-rules", data) { result in
      switch result {
      case .success(let data):
        do {
          let rules = try Constants.customJSONDecoder.decode(
            DynamicSearchRulesResults.self,
            from: data
          )
          completion(.success(rules))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func get(
    uid: String,
    _ completion: @escaping (Result<DynamicSearchRule, Swift.Error>) -> Void
  ) {
    request.get(api: "/dynamic-search-rules/\(uid)") { result in
      switch result {
      case .success(let data):
        guard let data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let rule = try Constants.customJSONDecoder.decode(
            DynamicSearchRule.self,
            from: data
          )
          completion(.success(rule))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func updateOrCreate(
    uid: String,
    ruleParams: DynamicSearchRuleParams,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void
  ) {
    let data: Data
    do {
      data = try Constants.customJSONEecoder.encode(ruleParams)
    } catch {
      completion(.failure(MeiliSearch.Error.invalidJSON))
      return
    }

    request.patch(api: "/dynamic-search-rules/\(uid)", data) { result in
      switch result {
      case .success(let data):
        do {
          let task = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
          completion(.success(task))
        } catch {
          completion(.failure(error))
        }
      case .failure(let error):
        completion(.failure(error))
      }
    }
  }

  func delete(
    uid: String,
    _ completion: @escaping (Result<TaskInfo, Swift.Error>) -> Void
  ) {
    request.delete(api: "/dynamic-search-rules/\(uid)") { result in
      switch result {
      case .success(let data):
        guard let data = data else {
          completion(.failure(MeiliSearch.Error.dataNotFound))
          return
        }
        do {
          let task = try Constants.customJSONDecoder.decode(TaskInfo.self, from: data)
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
