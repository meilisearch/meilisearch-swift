// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "meilisearch-swift",
  products: [
    .library(name: "MeiliSearch", targets: ["MeiliSearch"])
  ],
  dependencies: [
    // Support for dependabot for swift packages in dependabot
    // is in draft mode https://github.com/dependabot/dependabot-core/pull/3772
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.43.1"),
    .package(url: "https://github.com/meilisearch/meilisearch-swift.git", from: "0.12.0")
  ],
  targets: [
    .target(
      name: "MeiliSearch",
      dependencies: []
    ),
    .testTarget(
      name: "MeiliSearchUnitTests",
      dependencies: ["MeiliSearch"]
    ),
    .testTarget(
      name: "MeiliSearchIntegrationTests",
      dependencies: ["MeiliSearch"]
    )
  ]
)
