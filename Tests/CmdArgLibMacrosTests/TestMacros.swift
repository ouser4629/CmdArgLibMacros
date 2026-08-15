//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

//@testable import CmdArgLibCore
//@testable import CmdArgLibMacroSupport
@testable import CmdArgLibMacrosModule
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

let testMacros: [String: Macro.Type] = [
    "MainFunctionMacro": MainFunctionMacro.self,
    "CommandNodeMacro": CommandNodeMacro.self,
]
