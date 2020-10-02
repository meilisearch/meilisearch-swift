import Foundation

/**
 Each instance of MeiliSearch has three keys: a master, a private, and a public.
 Each key has a given set of permissions on the API routes.
 */
public struct Setting: Codable, Equatable {

    // MARK: Properties

    /// List of ranking rules for a given `Index`.
    public let rankingRules: [String]

    /// List of searchable attributes for a given `Index`.
    public let searchableAttributes: [String]

    /// List of displayed attributes for a given `Index`.
    public let displayedAttributes: [String]

    /// List of stop-words for a given `Index`.
    public let stopWords: [String]

    /// List of synonyms and its values for a given `Index`.
    public let synonyms: [String: [String]]

    public init(rankingRules: [String], searchableAttributes: [String], displayedAttributes: [String], stopWords: [String], synonyms: [String: [String]]) {
        self.rankingRules = rankingRules
        self.searchableAttributes = searchableAttributes
        self.displayedAttributes = displayedAttributes
        self.stopWords = stopWords
        self.synonyms = synonyms
    }

    /// Tries to decode the JSON object to Setting object.
    public init(from decoder: Decoder) throws {
        let values = try? decoder.container(keyedBy: CodingKeys.self)

        rankingRules = (try? values?.decodeIfPresent([String].self, forKey: .rankingRules)) ?? []
        searchableAttributes = (try? values?.decodeIfPresent([String].self, forKey: .searchableAttributes)) ?? ["*"]
        displayedAttributes = (try? values?.decodeIfPresent([String].self, forKey: .displayedAttributes)) ?? ["*"]
        stopWords = (try? values?.decodeIfPresent([String].self, forKey: .stopWords)) ?? []
        synonyms = (try? values?.decodeIfPresent([String: [String]].self, forKey: .synonyms)) ?? [:]
    }
}
