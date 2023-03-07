// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "meilisearch-swift",
  products: [
    .library(name: "MeiliSearch", targets: ["MeiliSearch"])
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
