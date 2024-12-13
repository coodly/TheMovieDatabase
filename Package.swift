// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

private let sharing = Target.Dependency.product(name: "Sharing", package: "swift-sharing")

let package = Package(
  name: "TheMovieDatabase",
  platforms: [.iOS(.v13), .tvOS(.v13), .macOS(.v14)],
  products: [
    .library(name: "TheMovieDatabase", targets: ["TheMovieDatabase"]),
    .library(name: "TMDBLogging", targets: ["TMDBLogging"]),
    .library(name: "TMDBModel", targets: ["TMDBModel"])
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-sharing.git", exact: "1.0.2")
  ],
  targets: [
    .target(
      name: "TheMovieDatabase",
      dependencies: [
        "TMDBLogging",
        "TMDBModel",
        
        sharing
      ],
      swiftSettings: [.swiftLanguageMode(.v5)]
    ),
    .target(
      name: "TMDBLogging",
      swiftSettings: [.swiftLanguageMode(.v5)]
    ),
    .target(
      name: "TMDBModel",
      dependencies: [
        "TMDBLogging",
        
        sharing
      ]
    ),
    .testTarget(
      name: "TheMovieDatabaseTests",
      dependencies: ["TheMovieDatabase"]),
  ]
)
