// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "DuckStack",
    dependencies: [
        .Package(url: "https://github.com/kylef/Commander", majorVersion: 0, minor: 6),
        .Package(url: "https://github.com/cpageler93/ChickGen", "0.2.0"),
        .Package(url: "https://github.com/cpageler93/RAML-Swift", "0.6.2")
    ]
)
