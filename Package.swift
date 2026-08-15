//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

// swift-tools-version: 6.2

import CompilerPluginSupport
import PackageDescription

// It is recommended that you use this module only when built with
// Swift 6.2 or later. Earlier toolchains either do not support macros
// or have unacceptable macro build performance.

let package = Package(
    name: "CmdArgLibMacros",
    platforms: [.macOS(.v12)],

    products: [
        .library(name: "CmdArgLibMacros", targets: ["CmdArgLibMacros"]),
    ],

    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", from: "602.0.0-latest"),
        .package(url: "https://github.com/ouser4629/CmdArgLibCore.git", branch: "main"),
    ],

    targets: [
        .target(
            name: "CmdArgLibMacros",
            dependencies: ["CmdArgLibMacrosModule"],
            path: "Sources/Macros/CmdArgLibMacros"
        ),
        .macro(
            name: "CmdArgLibMacrosModule",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
                "CmdArgLibMacroSupport",
            ],
            path: "Sources/Macros/CmdArgLibMacrosModule"
        ),
        .target(
            name: "CmdArgLibMacroSupport",
            dependencies: [
                "CmdArgLibCore"
            ],
            path: "Sources/Macros/CmdArgLibMacroSupport"
        ),
        .testTarget(
            name: "CmdArgLibMacrosTests",
            dependencies: [
                .product(name: "SwiftSyntaxMacrosTestSupport", package: "swift-syntax"),
                "CmdArgLibCore", "CmdArgLibMacroSupport", "CmdArgLibMacrosModule",
            ]
        ),
    ]
)
