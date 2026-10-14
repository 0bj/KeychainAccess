// swift-tools-version:6.2

//
//  Package.swift
//  KeychainAccess
//
//  Licensed under the MIT License. See LICENSE for details.
//

import PackageDescription

let package = Package(
    name: "KeychainAccess",
    platforms: [
        .macOS(.v15), .iOS(.v16), .tvOS(.v16), .watchOS(.v10)
    ],
    products: [
        .library(name: "KeychainAccess", targets: ["KeychainAccess"])
    ],
    targets: [
        .target(
            name: "KeychainAccess",
            path: "Lib/KeychainAccess"
        )
    ]
)
