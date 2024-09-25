// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "TheMovieDatabase",
  platforms: [.iOS(.v13), .tvOS(.v13)],
  products: [
    .library(name: "TheMovieDatabase", targets: ["TheMovieDatabase"]),
    .library(name: "TMDBLogging", targets: ["TMDBLogging"]),
    .library(name: "TMDBModel", targets: ["TMDBModel"])
  ],
  dependencies: [
    // Dependencies declare other packages that this package depends on.
    // .package(url: /* package url */, from: "1.0.0"),
  ],
  targets: [
    .target(
      name: "TheMovieDatabase",
      dependencies: [
        "TMDBLogging",
        "TMDBModel"
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
        "TMDBLogging"
      ]
    ),
    .testTarget(
      name: "TheMovieDatabaseTests",
      dependencies: ["TheMovieDatabase"]),
  ]
)
