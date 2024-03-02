// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BookshelfFeature",
	defaultLocalization: "en",
	platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "BookshelfFeature",
            targets: ["BookshelfFeature"]
		),
    ],
	dependencies: [
		.package(name: "Domain", path: "./Domain"),
		.package(name: "Shared", path: "./Shared"),
		.package(name: "Services", path: "./Services"),
		.package(name: "AudioListFeature", path: "./AudioListFeature"),
		.package(url: "https://github.com/pointfreeco/swift-composable-architecture.git", exact: "1.5.5"),
	],
    targets: [
        .target(
			name: "BookshelfFeature",
			dependencies: [
				"Domain",
				"Shared",
				.product(name: "DomainMock", package: "Domain"),
				.product(name: "AudioService", package: "Services"),
				.product(name: "FileService", package: "Services"),
				.product(name: "StorageService", package: "Services"),
				.product(name: "BookMetaInfoService", package: "Services"),
				.product(name: "AudioListFeature", package: "AudioListFeature"),
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture")
			]
		),
        .testTarget(
            name: "BookshelfFeatureTests",
            dependencies: [
				"BookshelfFeature"
			]
		),
    ]
)
