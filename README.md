<p align="center">
  <img src="https://github.com/meilisearch/meilisearch-swift/blob/master/assets/logo.svg" alt="MeiliSearch-Swift" width="200" height="200" />
</p>

<h1 align="center">MeiliSearch-Swift</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://blog.meilisearch.com">Blog</a> |
  <a href="https://fr.linkedin.com/company/meilisearch">LinkedIn</a> |
  <a href="https://twitter.com/meilisearch">Twitter</a> |
  <a href="https://meilisearch.github.io/meilisearch-swift/">Documentation</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/meilisearch-swift/actions"><img src="https://github.com/meilisearch/meilisearch-swift/workflows/Tests/badge.svg" alt="GtiHub Workflow Status"></a>
  <a href="https://github.com/meilisearch/meilisearch-swift/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
  <a href="https://slack.meilisearch.com"><img src="https://img.shields.io/badge/slack-MeiliSearch-blue.svg?logo=slack" alt="Slack"></a>
  <a href="https://app.bors.tech/repositories/28499"><img src="https://bors.tech/images/badge_small.svg" alt="Bors enabled"></a>
</p>

<p align="center">⚡ Lightning Fast, Ultra Relevant, and Typo-Tolerant Search Engine MeiliSearch client written in Swift 🍎</p>

**MeiliSearch-Swift** is a client for **MeiliSearch** written in Swift. **MeiliSearch** is a powerful, fast, open-source, easy to use and deploy search engine. Both searching and indexing are highly customizable. Features such as typo-tolerance, filters, and synonyms are provided out-of-the-box.
For more information about features go to [our Swift documentation](https://meilisearch.github.io/meilisearch-swift/).

## Features
* Complete full API wrapper
* Easy to install, deploy, and maintain
* Highly customizable
* No external dependencies
* Thread safe
* Uses Codable

## Get started

### Swift Package Manager

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **MeiliSearch-Swift** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git")
]
```

## Basic setup

Make sure to firstly setup your `MeiliSearch` server. Please follow this getting started [here](https://docs.meilisearch.com/guides/introduction/quick_start_guide.html).

To do a simply search using the client, you can create a Swift script like this:

```swift
import MeiliSearch

func searchForMovies() {

    // Create a new client instance of MeiliSearch with the default host.
    let client = try! MeiliSearch()

    // Create a new search request with "botman" as query.
    let searchParameters = SearchParameters.query("botman")

    // Typealias that represents the result from Meili.
    typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

    // Call the function search and wait for the closure result.
    self.client.search(UID: "movies", searchParameters) { (result: MeiliResult) in
        switch result {
        case .success(let searchResult):
            print(searchResult)
        case .failure(let error):
            print(error)
        }
    }

}

private struct Movie: Codable, Equatable {

    let id: Int
    let title: String
    let poster: String
    let overview: String
    let releaseDate: Date

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case poster
        case overview
        case releaseDate = "release_date"
    }

}

```

## Compatibility with MeiliSearch

This package only guarantees the compatibility with the [version v0.17.0 of MeiliSearch](https://github.com/meilisearch/MeiliSearch/releases/tag/v0.17.0).

## Demo

To try out a demo you will need to go to its directory in `Demos/`. In that directory you can either:

 - Open the SwiftPM project in Xcode and press run, or
 - Run `swift build` or `swift run` in the terminal.

### Vapor

Please check the Vapor Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/master/Demos/VaporDemo).

### Perfect

Please check the Perfect Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/master/Demos/PerfectDemo).

## Development Workflow and Contributing

Any new contribution is more than welcome in this project!

If you want to know more about the development workflow or want to contribute, please visit our [contributing guidelines](/CONTRIBUTING.md) for detailed instructions!

## Contact

Feel free to contact us about any questions you may have:
* At [bonjour@meilisearch.com](mailto:bonjour@meilisearch.com): English or French is welcome! 🇬🇧 🇫🇷
* Via the chat box available on every page of [our documentation](https://docs.meilisearch.com/) and on [our landing page](https://www.meilisearch.com/).
* Join our [Slack community](https://slack.meilisearch.com/).
* By opening an issue.

Any suggestion or feedback is highly appreciated. Thank you for your support!

Swift programming language from Apple

<hr>

**MeiliSearch** provides and maintains many **SDKs and Integration tools** like this one. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
