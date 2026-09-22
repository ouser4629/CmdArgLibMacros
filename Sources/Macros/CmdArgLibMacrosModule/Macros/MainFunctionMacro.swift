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
