// swift-tools-version:4.2

import PackageDescription

let package = Package(
	name: "PerfectTemplate",
	products: [
		.executable(name: "PerfectTemplate", targets: ["PerfectTemplate"])
	],
	dependencies: [
		.package(url: "https://github.com/PerfectlySoft/Perfect-HTTPServer.git", from: "3.0.0"),
    .package(path: "../../")
	],
	targets: [
		.target(name: "PerfectTemplate", dependencies: [
      .product(name: "PerfectHTTPServer"),
      .product(name: "MeiliSearch", package: "meilisearch-swift")
		])
	]
)
