// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AudioListFeature",
	platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "AudioListFeature",
            targets: ["AudioListFeature"]
		),
    ],
	dependencies: [
		.package(name: "Domain", path: "./Domain"),
		.package(name: "Shared", path: "./Shared"),
		.package(name: "Services", path: "./Services"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.5.5"),
	],
    targets: [
        .target(
			name: "AudioListFeature",
			dependencies: [
				"Domain",
				"Shared",
				.product(name: "AudioService", package: "Services"),
				.product(name: "FileService", package: "Services"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
        .testTarget(
            name: "AudioListFeatureTests",
            dependencies: [
				"AudioListFeature",
				.product(name: "DomainMock", package: "Domain"),
				.product(name: "AudioService", package: "Services"),
				.product(name: "FileService", package: "Services"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
    ]
)
