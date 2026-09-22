// Copyright (c) 2025-2026 Peter Summerland LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

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
