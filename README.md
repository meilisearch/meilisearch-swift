<p align="center">
  <img src="https://github.com/meilisearch/meilisearch-swift/blob/main/assets/logo.svg" alt="MeiliSearch-Swift" width="200" height="200" />
</p>

<h1 align="center">MeiliSearch Swift</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/MeiliSearch">MeiliSearch</a> |
  <a href="https://meilisearch.github.io/meilisearch-swift/">Documentation</a> |
  <a href="https://slack.meilisearch.com">Slack</a> |
  <a href="https://roadmap.meilisearch.com/tabs/1-under-consideration">Roadmap</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/meilisearch-swift/actions"><img src="https://github.com/meilisearch/meilisearch-swift/workflows/Tests/badge.svg" alt="GitHub Workflow Status"></a>
  <a href="https://github.com/meilisearch/meilisearch-swift/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
  <a href="https://app.bors.tech/repositories/28499"><img src="https://bors.tech/images/badge_small.svg" alt="Bors enabled"></a>
</p>

<p align="center">⚡ The MeiliSearch API client written for Swift 🍎</p>

**MeiliSearch Swift** is the MeiliSearch API client for Swift developers.

**MeiliSearch** is an open-source search engine. [Discover what MeiliSearch is!](https://github.com/meilisearch/MeiliSearch)

## Table of Contents <!-- omit in toc -->

- [📖 Documentation](#-documentation)
- [🔧 Installation](#-installation)
- [🎬 Getting Started](#-getting-started)
- [🤖 Compatibility with MeiliSearch](#-compatibility-with-meilisearch)
- [💡 Learn More](#-learn-more)
- [⚙️ Development Workflow and Contributing](#️-development-workflow-and-contributing)
- [📜 Demos](#-demos)

## 📖 Documentation

For more information about this API see our [Swift documentation](https://meilisearch.github.io/meilisearch-swift/).

For more information about MeiliSearch see our [Documentation](https://docs.meilisearch.com/learn/tutorials/getting_started.html) or our [API References](https://docs.meilisearch.com/reference/api/).

## 🔧 Installation

### With Cocoapods <!-- omit in toc -->

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

**MeiliSearch-Swift** is available through CocoaPods. To install it, add the following line to your Podfile:

```ruby
pod 'MeiliSearch'
```

Then, run the following command:

```bash
pod install
```

This will download the latest version of MeiliSearch pod and prepare the `xcworkspace`.

### With the Swift Package Manager <!-- omit in toc -->

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **MeiliSearch-Swift** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git")
]
```

### 🏃‍♀️ Run MeiliSearch <!-- omit in toc -->

There are many easy ways to [download and run a MeiliSearch instance](https://docs.meilisearch.com/reference/features/installation.html#download-and-launch).

For example, if you use Docker:

```bash
docker pull getmeili/meilisearch:latest # Fetch the latest version of MeiliSearch image from Docker Hub
docker run -it --rm -p 7700:7700 getmeili/meilisearch:latest ./meilisearch --master-key=masterKey
```

NB: you can also download MeiliSearch from **Homebrew** or **APT**.

## 🎬 Getting Started

To do a simply search using the client, you can create a Swift script like this:

#### Add documents <!-- omit in toc -->

```swift
    import MeiliSearch

    // Create a new client instance of MeiliSearch.
    let client = try! MeiliSearch(host: "http://localhost:7700")

    struct Movie: Codable, Equatable {
        let id: Int
        let title: String
        let genres: [String]
    }

    let movies: [Movie] = [
        Movie(id: 1, title: "Carol", genres: ["Romance", "Drama"]),
        Movie(id: 2, title: "Wonder Woman", genres: ["Action", "Adventure"]),
        Movie(id: 3, title: "Life of Pi", genres: ["Adventure", "Drama"]),
        Movie(id: 4, title: "Mad Max: Fury Road", genres: ["Adventure", "Science Fiction"]),
        Movie(id: 5, title: "Moana", genres: ["Fantasy", "Action"]),
        Movie(id: 6, title: "Philadelphia", genres: ["Drama"])
    ]

    let semaphore = DispatchSemaphore(value: 0)

    // An index is where the documents are stored.
    // The uid is the unique identifier to that index.
    let indexUid = "movies"

    // If the index 'movies' does not exist, MeiliSearch creates it when you first add the documents.
    client.addDocuments(
        UID: indexUid,
        documents: movies,
        primaryKey: nil
    ) { result in
        switch result {
        case .success(let update):
            print(update) // => Update(updateId: 0)
        case .failure(let error):
            print(error.localizedDescription)
        }
        semaphore.signal()
      }
    semaphore.wait()
```

With the `updateId`, you can check the status (`enqueued`, `processing`, `processed` or `failed`) of your documents addition using the [update endpoint](https://docs.meilisearch.com/reference/api/updates.html#get-an-update-status).

#### Basic Search <!-- omit in toc -->
```swift

let semaphore = DispatchSemaphore(value: 0)

// Typealias that represents the result from MeiliSearch.
typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

// Call the function search and wait for the closure result.
client.search(UID: "movies", SearchParameters( query: "philoudelphia" )) { (result: MeiliResult) in
    switch result {
    case .success(let searchResult):
        dump(searchResult)
    case .failure(let error):
        print(error.localizedDescription)
    }
    semaphore.signal()
}
semaphore.wait()

```

Output:

```bash
 MeiliSearch.SearchResult<SwiftWork.(unknown context at $10d9e7f3c).Movie>
  ▿ hits: 1 element
    ▿ SwiftWork.(unknown context at $10d9e7f3c).Movie
      - id: 6
      - title: "Philadelphia"
      ▿ genres: 1 element
        - "Drama"
  - offset: 0
  - limit: 20
  - nbHits: 1
  ▿ exhaustiveNbHits: Optional(false)
    - some: false
  - facetsDistribution: nil
  - exhaustiveFacetsCount: nil
  ▿ processingTimeMs: Optional(1)
    - some: 1
  ▿ query: Optional("philoudelphia")
    - some: "philoudelphia"
```

Since MeiliSearch is typo-tolerant, the movie `philadelphia` is a valid search response to `philoudelphia`.

## 🤖 Compatibility with MeiliSearch

This package only guarantees the compatibility with the [version v0.22.0 of MeiliSearch](https://github.com/meilisearch/MeiliSearch/releases/tag/v0.22.0).

## 💡 Learn More

The following sections may interest you:

- **Manipulate documents**: see the [API references](https://docs.meilisearch.com/reference/api/documents.html) or read more about [documents](https://docs.meilisearch.com/learn/core_concepts/documents.html).
- **Search**: see the [API references](https://docs.meilisearch.com/reference/api/search.html) or follow our guide on [search parameters](https://docs.meilisearch.com/reference/features/search_parameters.html).
- **Manage the indexes**: see the [API references](https://docs.meilisearch.com/reference/api/indexes.html) or read more about [indexes](https://docs.meilisearch.com/learn/core_concepts/indexes.html).
- **Configure the index settings**: see the [API references](https://docs.meilisearch.com/reference/api/settings.html) or follow our guide on [settings parameters](https://docs.meilisearch.com/reference/features/settings.html).

## ⚙️ Development Workflow and Contributing

Any new contribution is more than welcome in this project!

If you want to know more about the development workflow or want to contribute, please visit our [contributing guidelines](/CONTRIBUTING.md) for detailed instructions!

## 📜 Demos

To try out a demo you will need to go to its directory in `Demos/`. In that directory you can either:

 - Open the SwiftPM project in Xcode and press run, or
 - Run `swift build` or `swift run` in the terminal.

### Vapor <!-- omit in toc -->

Please check the Vapor Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/main/Demos/VaporDemo).

### Perfect <!-- omit in toc -->

Please check the Perfect Demo source code [here](https://github.com/meilisearch/meilisearch-swift/tree/main/Demos/PerfectDemo).

<hr>

**MeiliSearch** provides and maintains many **SDKs and Integration tools** like this one. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
