// swift-tools-version:6.2

//  Package.swift
//  KeychainAccess
//
//  Created by kishikawa katsumi on 2015/12/4.
//  Copyright (c) 2015 kishikawa katsumi. All rights reserved.
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
          path: "Lib/KeychainAccess",
          linkerSettings: [.unsafeFlags(["-Xlinker", "-no_application_extension"])])
    ]
)
