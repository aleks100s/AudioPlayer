// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Services",
	platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "FileService",
            targets: ["FileService"]
		),
		.library(
			name: "AudioService",
			targets: ["AudioService"]
		),
		.library(
			name: "StorageService",
			targets: ["StorageService"]
		),
		.library(
			name: "BookMetaInfoService",
			targets: ["BookMetaInfoService"]
		)
    ],
	dependencies: [
		.package(name: "Domain", path: "./Domain"),
		.package(name: "Shared", path: "./Shared"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.5.5")
	],
    targets: [
        .target(
			name: "FileService",
			dependencies: [
				"Domain",
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
		.target(
			name: "AudioService",
			dependencies: [
				"Domain",
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
		.target(
			name: "StorageService",
			dependencies: [
				"Domain",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
		.target(
			name: "BookMetaInfoService",
			dependencies: [
				"Domain",
				"Shared",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		)
    ]
)
