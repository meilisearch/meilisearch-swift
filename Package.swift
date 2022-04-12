// swift-tools-version:5.2

import PackageDescription

let package = Package(
  name: "meilisearch-swift",
  platforms: [
    .iOS(.v12),
    .tvOS(.v12),
    .watchOS(.v5),
    .macOS(.v10_15)
  ],
  products: [
    .library(name: "MeiliSearch", targets: ["MeiliSearch"])
  ],
  dependencies: [
    // Support for dependabot for swift packages in dependabot
    // is in draft mode https://github.com/dependabot/dependabot-core/pull/3772
    .package(url: "https://github.com/realm/SwiftLint.git", from: "0.43.1"),
    .package(url: "https://github.com/vapor/jwt-kit.git", from: "4.0.0")
  ],
  targets: [
    .target(
      name: "MeiliSearch",
      dependencies: [
        .product(name: "JWTKit", package: "jwt-kit")
      ]
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
