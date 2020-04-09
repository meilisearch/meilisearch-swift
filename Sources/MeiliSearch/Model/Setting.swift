import Foundation

/**
 Each instance of MeiliSearch has three keys: a master, a private, and a public.
 Each key has a given set of permissions on the API routes.
*/
public struct Setting: Codable, Equatable {

    // MARK: Properties

    public let rankingRules: [String]

    public let searchableAttributes: [String]

    public let displayedAttributes: [String]

    public let stopWords: [String]

    public let synonyms: [String: [String]]

    public let acceptNewFields: Bool

    public init(from decoder: Decoder) throws {
        let values = try? decoder.container(keyedBy: CodingKeys.self)
        rankingRules = (try? values?.decodeIfPresent([String].self, forKey: .rankingRules)) ?? []
        searchableAttributes = (try? values?.decodeIfPresent([String].self, forKey: .searchableAttributes)) ?? []
        displayedAttributes = (try? values?.decodeIfPresent([String].self, forKey: .displayedAttributes)) ?? []
        stopWords = (try? values?.decodeIfPresent([String].self, forKey: .stopWords)) ?? []
        synonyms = (try? values?.decodeIfPresent([String: [String]].self, forKey: .synonyms)) ?? [:]
        acceptNewFields = (try? values?.decodeIfPresent(Bool.self, forKey: .acceptNewFields)) ?? false
    }

}
