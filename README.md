<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/main/assets/logos/meilisearch_swift.svg" alt="meilisearch-swift" width="200" height="200" />
</p>

<h1 align="center">Meilisearch Swift</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch">Meilisearch</a> |
  <a href="https://meilisearch.github.io/meilisearch-swift/">Documentation</a> |
  <a href="https://slack.meilisearch.com">Slack</a> |
  <a href="https://roadmap.meilisearch.com/tabs/1-under-consideration">Roadmap</a> |
  <a href="https://www.meilisearch.com">Website</a> |
  <a href="https://docs.meilisearch.com/faq">FAQ</a>
</h4>

<p align="center">
  <a href="https://github.com/meilisearch/meilisearch-swift/actions"><img src="https://github.com/meilisearch/meilisearch-swift/workflows/Tests/badge.svg" alt="GitHub Workflow Status"></a>
  <a href="https://github.com/meilisearch/meilisearch-swift/blob/main/LICENSE"><img src="https://img.shields.io/badge/license-MIT-informational" alt="License"></a>
  <a href="https://ms-bors.herokuapp.com/repositories/45"><img src="https://bors.tech/images/badge_small.svg" alt="Bors enabled"></a>
</p>

<p align="center">⚡ The Meilisearch API client written for Swift 🍎</p>

**Meilisearch Swift** is the Meilisearch API client for Swift developers.

**Meilisearch** is an open-source search engine. [Discover what Meilisearch is!](https://github.com/meilisearch/meilisearch)

## Table of Contents <!-- omit in toc -->

- [🎃 Hacktoberfest](#-hacktoberfest)
- [📖 Documentation](#-documentation)
- [🔧 Installation](#-installation)
- [🎬 Getting Started](#-getting-started)
- [🤖 Compatibility with Meilisearch](#-compatibility-with-meilisearch)
- [💡 Learn More](#-learn-more)
- [⚙️ Development Workflow and Contributing](#️-development-workflow-and-contributing)
- [📜 Demos](#-demos)

## 🎃 Hacktoberfest

It’s Hacktoberfest 2022 @Meilisearch

[Hacktoberfest](https://hacktoberfest.com/) is a celebration of the open-source community. This year, and for the third time in a row, Meilisearch is participating in this fantastic event.

You’d like to contribute? Don’t hesitate to check out our [contributing guidelines](./CONTRIBUTING.md).

## 📖 Documentation

For more information about this API see our [Swift documentation](https://meilisearch.github.io/meilisearch-swift/).

For more information about Meilisearch see our [Documentation](https://docs.meilisearch.com/learn/tutorials/getting_started.html) or our [API References](https://docs.meilisearch.com/reference/api/).

## 🔧 Installation

### With Cocoapods <!-- omit in toc -->

[CocoaPods](https://cocoapods.org/) is a dependency manager for Cocoa projects.

**Meilisearch-Swift** is available through CocoaPods. To install it, add the following line to your Podfile:

```ruby
pod 'MeiliSearch'
```

Then, run the following command:

```bash
pod install
```

This will download the latest version of Meilisearch pod and prepare the `xcworkspace`.

### With the Swift Package Manager <!-- omit in toc -->

The [Swift Package Manager](https://swift.org/package-manager/) is a tool for automating the distribution of Swift code and is integrated into the `swift` compiler.

Once you have your Swift package set up, adding **Meilisearch-Swift** as a dependency is as easy as adding it to the `dependencies` value of your `Package.swift`.

```swift
dependencies: [
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "0.14.1")
]
```

### 🏃‍♀️ Run Meilisearch <!-- omit in toc -->

There are many easy ways to [download and run a Meilisearch instance](https://docs.meilisearch.com/reference/features/installation.html#download-and-launch).

For example, using the `curl` command in your [Terminal](https://itconnect.uw.edu/learn/workshops/online-tutorials/web-publishing/what-is-a-terminal/):

```sh
#Install Meilisearch
curl -L https://install.meilisearch.com | sh

# Launch Meilisearch
./meilisearch --master-key=masterKey
```

NB: you can also download Meilisearch from **Homebrew** or **APT** or even run it using **Docker**.

## 🎬 Getting Started

To do a simply search using the client, you can create a Swift script like this:

#### Add documents <!-- omit in toc -->

```swift
    import MeiliSearch

    // Create a new client instance of Meilisearch.
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
    let index = client.index("movies")

    // If the index 'movies' does not exist, Meilisearch creates it when you first add the documents.
    index.addDocuments(
        documents: movies,
        primaryKey: nil
    ) { result in
        switch result {
        case .success(let task):
            print(task) // => Task(uid: 0, status: "enqueued", ...)
        case .failure(let error):
            print(error.localizedDescription)
        }
        semaphore.signal()
      }
    semaphore.wait()
```

With the `uid` of the task, you can check the status (`enqueued`, `processing`, `succeeded` or `failed`) of your documents addition using the [update endpoint](https://docs.meilisearch.com/learn/advanced/asynchronous_operations.html#task-status).

#### Basic Search <!-- omit in toc -->

```swift

let semaphore = DispatchSemaphore(value: 0)

// Typealias that represents the result from Meilisearch.
typealias MeiliResult = Result<SearchResult<Movie>, Swift.Error>

// Call the function search and wait for the closure result.
client.index("movies").search(SearchParameters( query: "philoudelphia" )) { (result: MeiliResult) in
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
  - estimatedTotalHits: 1
  - facetDistribution: nil
  ▿ processingTimeMs: Optional(1)
    - some: 1
  ▿ query: Optional("philoudelphia")
    - some: "philoudelphia"
```

Since Meilisearch is typo-tolerant, the movie `philadelphia` is a valid search response to `philoudelphia`.

## 🤖 Compatibility with Meilisearch

This package only guarantees the compatibility with the [version v0.29.0 of Meilisearch](https://github.com/meilisearch/meilisearch/releases/tag/v0.29.0).

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

**Meilisearch** provides and maintains many **SDKs and Integration tools** like this one. We want to provide everyone with an **amazing search experience for any kind of project**. If you want to contribute, make suggestions, or just know what's going on right now, visit us in the [integration-guides](https://github.com/meilisearch/integration-guides) repository.
