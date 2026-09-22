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
