<p align="center">
  <img src="https://raw.githubusercontent.com/meilisearch/integration-guides/main/assets/logos/meilisearch_swift.svg" alt="meilisearch-swift" width="200" height="200" />
</p>

<h1 align="center">Meilisearch Swift</h1>

<h4 align="center">
  <a href="https://github.com/meilisearch/meilisearch">Meilisearch</a> |
  <a href="https://www.meilisearch.com/cloud?utm_campaign=oss&utm_source=github&utm_medium=meilisearch-swift">Meilisearch Cloud</a> |
  <a href="https://meilisearch.github.io/meilisearch-swift/">Documentation</a> |
  <a href="https://discord.meilisearch.com">Discord</a> |
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

**Meilisearch** is an open-source search engine. [Learn more about Meilisearch.](https://github.com/meilisearch/meilisearch)

## Table of Contents <!-- omit in TOC -->

- [📖 Documentation](#-documentation)
- [🔧 Installation](#-installation)
- [🚀 Getting started](#-getting-started)
- [🤖 Compatibility with Meilisearch](#-compatibility-with-meilisearch)
- [💡 Learn more](#-learn-more)
- [⚙️ Contributing](#️-contributing)
- [📜 Demos](#-demos)

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
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "0.16.0")
]
```

### Run Meilisearch <!-- omit in toc -->

⚡️ **Launch, scale, and streamline in minutes with Meilisearch Cloud**—no maintenance, no commitment, cancel anytime. [Try it free now](https://cloud.meilisearch.com/login?utm_campaign=oss&utm_source=github&utm_medium=meilisearch-swift).

🪨  Prefer to self-host? [Download and deploy](https://www.meilisearch.com/docs/learn/self_hosted/getting_started_with_self_hosted_meilisearch?utm_campaign=oss&utm_source=github&utm_medium=meilisearch-swift) our fast, open-source search engine on your own infrastructure.

## 🚀 Getting started

To do a simple search using the client, you can create a Swift script like this:

#### Add documents <!-- omit in toc -->

```swift
    import MeiliSearch

    // Create a new client instance of Meilisearch.
    // Note: You must provide a fully qualified URL including scheme.
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
            print(task) // => Task(uid: 0, status: Task.Status.enqueued, ...)
        case .failure(let error):
            print(error.localizedDescription)
        }
        semaphore.signal()
      }
    semaphore.wait()
```

With the `uid` of the task, you can check the status (`enqueued`, `canceled`, `processing`, `succeeded` or `failed`) of your documents addition using the [update endpoint](https://docs.meilisearch.com/learn/advanced/asynchronous_operations.html#task-status).

#### Basic Search <!-- omit in toc -->

```swift
do {
  // Call the search function and wait for the result.
  let result: SearchResult<Movie> = try await client.index("movies").search(SearchParameters(query: "philoudelphia"))
  dump(result)
} catch {
  print(error.localizedDescription)
}
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

> Note: All package APIs support closure-based results for backwards compatibility. Newer async/await variants are being added under [issue 332](https://github.com/meilisearch/meilisearch-swift/issues/332).

#### Custom Search With Filters <!-- omit in toc -->

If you want to enable filtering, you must add your attributes to the `filterableAttributes` index setting.

```swift
index.updateFilterableAttributes(["id", "genres"]) { result in
    // Handle Result in Closure
}
```

You only need to perform this operation once.

Note that MeiliSearch will rebuild your index whenever you update `filterableAttributes`. Depending on the size of your dataset, this might take time. You can track the process using the [update status](https://docs.meilisearch.com/reference/api/updates.html#get-an-update-status).

Then, you can perform the search:

```swift
let searchParameters = SearchParameters(
    query: "wonder",
    filter: "id > 1 AND genres = Action"
)

let response: Searchable<Meteorite> = try await index.search(searchParameters)
```

```json
{
  "hits": [
    {
      "id": 2,
      "title": "Wonder Woman",
      "genres": ["Action","Adventure"]
    }
  ],
  "offset": 0,
  "limit": 20,
  "nbHits": 1,
  "processingTimeMs": 0,
  "query": "wonder"
}
```

## 🤖 Compatibility with Meilisearch

This package guarantees compatibility with [version v1.x of Meilisearch](https://github.com/meilisearch/meilisearch/releases/latest), but some features may not be present. Please check the [issues](https://github.com/meilisearch/meilisearch-swift/issues?q=is%3Aissue+is%3Aopen+label%3A%22good+first+issue%22+label%3Aenhancement) for more info.

## 💡 Learn more

The following sections in our main documentation website may interest you:

- **Manipulate documents**: see the [API references](https://docs.meilisearch.com/reference/api/documents.html) or read more about [documents](https://docs.meilisearch.com/learn/core_concepts/documents.html).
- **Search**: see the [API references](https://docs.meilisearch.com/reference/api/search.html) or follow our guide on [search parameters](https://docs.meilisearch.com/reference/features/search_parameters.html).
- **Manage the indexes**: see the [API references](https://docs.meilisearch.com/reference/api/indexes.html) or read more about [indexes](https://docs.meilisearch.com/learn/core_concepts/indexes.html).
- **Configure the index settings**: see the [API references](https://docs.meilisearch.com/reference/api/settings.html) or follow our guide on [settings parameters](https://docs.meilisearch.com/reference/features/settings.html).

## ⚙️ Contributing

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
