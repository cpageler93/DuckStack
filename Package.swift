// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "DuckStack",
    dependencies: [
        .Package(url: "https://github.com/kylef/Commander", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/cpageler93/ChickGen", majorVersion: 0, minor: 1),
        .Package(url: "https://github.com/cpageler93/RAML-Swift", majorVersion: 0, minor: 1)
    ]
)
