import PackageDescription

let package = Package(
    name: "StructuredData",
    dependencies: [
        .Package(url: "https://github.com/open-swift/C7.git", majorVersion: 0, minor: 9),
        .Package(url: "https://github.com/Zewo/Reflection.git", majorVersion: 0, minor: 7)
    ]
)
