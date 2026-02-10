// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "PhdKhaleghiFormola",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "PhdKhaleghiFormola",
            targets: ["PhdKhaleghiFormola"]
        )
    ],
    targets: [
        .executableTarget(
            name: "PhdKhaleghiFormola",
            path: "Sources"
        )
    ],
)
