// swift-tools-version: 5.9
// GuessingGame v3.0.0 — native macOS app, Swift + SwiftUI. No SDL, no bundling hacks.

import PackageDescription

let package = Package(
    name: "GuessingGame",
    platforms: [
        .macOS(.v14)
    ],
    targets: [
        .executableTarget(
            name: "GuessingGame",
            path: "Sources/GuessingGame"
        )
    ]
)
