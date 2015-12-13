import PackageDescription

let package = Package(
    name: "MongoDB",
    dependencies: [
        .Package(url: "https://github.com/PureSwift/CMongoDB.git", majorVersion: 1),
        .Package(url: "https://github.com/PureSwift/SwiftFoundation.git", majorVersion: 1)
    ],
    targets: [
        Target(
            name: "UnitTests",
            dependencies: [.Target(name: "MongoDB")]),
        Target(
            name: "MongoDB")
    ]
)