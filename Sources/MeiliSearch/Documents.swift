
class Documents {

    let request: Request
    
    init (config: Config) {
        request = Request(config: config)
    }

    func getDocument(uid: String, identifier: String) {
        let requestQuery: String = "/indexes/\(uid)/documents/\(identifier)"
        request.get(api: requestQuery) { response in
            print(response)
        }
    }

    func getDocuments(uid: String) -> String {
        let requestQuery: String = "/indexes/\(uid)/documents"
        // return request.get(requestQuery)
        return ""
    }

    func getDocuments(uid: String, limit: Int) -> String {
        let requestQuery: String = "/indexes/\(uid)/documents?limit=\(limit)"
        // return request.get(requestQuery)
        return ""
    }

}