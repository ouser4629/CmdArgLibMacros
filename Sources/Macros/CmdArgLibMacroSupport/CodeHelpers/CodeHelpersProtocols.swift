//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibCore

// This is a protocol because actual FuncInfo,defined in T_CmdArgLibMacros,
// depends on SwiftSyntax which we do not import in CmdArgLibMacroSupport.
// We do, however, need to work with FuncParameters stuff in CmdArgLibMacroSupport.
public protocol FuncInfoProtocol {
    var name: String { get }
    var callName: String { get }
    var genericParameterClause: String { get }
    var modifiers: String { get }  // e.g., public static
    var wrappedFunctionReturnEffects: String { get }
    var returnType: String { get }
    var returnPrefix: String { get }
    var callModifiers: String { get }  // e.g., try await
    var wrappedFunctionThrows: Bool { get }
    var parameterInfos: [CmdFunctionParameterInfo] { get }
    var commandType: String? { get }
    var stateParameterWasSynthesized: Bool { get }
}

/// Info for a command function parameter - used by macros
public struct CmdFunctionParameterInfo {
    public let name: String
    public let parameterLabel: String
    public let typeName: String
    public let defaultValue: String?

    public var isMeta: Bool {
        typeName == "MetaFlag" || typeName.hasPrefix("MetaOption")
    }

    public init(name: String,
                parameterLabel: String?  = nil,
                typeName: String,
                defaultValue: String? = nil)
    {
        self.name = name
        self.parameterLabel = parameterLabel ?? name
        self.typeName = typeName
        self.defaultValue = defaultValue
    }
}
