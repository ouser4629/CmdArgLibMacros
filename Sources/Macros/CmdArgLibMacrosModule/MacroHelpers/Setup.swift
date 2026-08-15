//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

//import CmdArgLibMacroSupport
import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

typealias Code = String

func setup(
    with node: AttributeSyntax,
    and funcSyntax: FunctionDeclSyntax ) ->(FuncInfo?, Code?, [Diagnostic])
{
    var funcInfo: FuncInfo
    var diagnostics: [Diagnostic]
    (funcInfo, diagnostics) = makeFuncInfo(funcSyntax: funcSyntax)
    let (contextCode, contextDiagnostics) = makeContextCode(funcInfo, node)
    diagnostics += contextDiagnostics
    return (funcInfo, contextCode, diagnostics)
}

func ensureFuncSyntax(_ declaration: some DeclSyntaxProtocol,
                      _ context: MacroExpansionContext) -> FunctionDeclSyntax?
{
    guard let funcDecl = declaration.as(FunctionDeclSyntax.self) else {
        let errorMsg = ("Only applies to functions")
        let msg = MacroUsageDiagnosticMessage(message: errorMsg)
        context.diagnose(msg.diagnostic(node: declaration))
        return nil
    }
    return funcDecl
}
