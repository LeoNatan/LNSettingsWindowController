// swift-tools-version:6.0

import PackageDescription

let package = Package(
	name: "LNSettingsWindowController",
	platforms: [
		.macOS(.v11)
	],
	products: [
		.library(
			name: "LNSettingsWindowController",
			type: .dynamic,
			targets: ["LNSettingsWindowController"]),
		.library(
			name: "LNSettingsWindowController-Static",
			type: .static,
			targets: ["LNSettingsWindowController"]),
	],
	dependencies: [],
	targets: [
		.target(
			name: "LNSettingsWindowController",
			dependencies: [],
			exclude: [
			],
			publicHeadersPath: "."
		),
	]
)
