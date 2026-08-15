//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibMacroSupport
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

//typealias Name = String

public struct MainFunctionMacro: PeerMacro {

    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext ) throws -> [SwiftSyntax.DeclSyntax]
    {
        guard let funcSyntax = ensureFuncSyntax(declaration, context) else { return [] }
        let (funcInfo, maybeContextCode, diagnostics) = setup(with: node, and: funcSyntax)
        guard let contextCode = maybeContextCode, diagnostics.isEmpty else {
            for diagnostic in diagnostics { context.diagnose(diagnostic) }
            return []
        }
        let (runCode1, runContextCode, runCode2, mainCode) = makeMainFunctionCode(contextCode, funcInfo!)
        return [DeclSyntax("\(raw: runCode1)"), DeclSyntax("\(raw: runCode2)"), DeclSyntax("\(raw: runContextCode)"), DeclSyntax("\(raw: mainCode)")]
    }
}
