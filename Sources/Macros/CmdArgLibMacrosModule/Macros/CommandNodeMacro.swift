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

public struct CommandNodeMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext ) throws -> [SwiftSyntax.DeclSyntax]
    {
        guard let funcSyntax = ensureFuncSyntax(declaration, context) else { return [] }
        let (maybeFuncInfo, maybeContextCode, setupDiagnostics) = setup(with: node, and: funcSyntax)
        let (funcInfo, stateDiagnostics) = ensureStateParameter(funcInfo: maybeFuncInfo, funcSyntax: funcSyntax)
        var diagnostics = setupDiagnostics + stateDiagnostics
        let synopsisCode = makeCode(for: "synopsis", from: node)
        if synopsisCode.isEmpty {
            let msg = MacroUsageDiagnosticMessage(message: "Missing command synposis.")
            diagnostics.append(msg.diagnostic(node: funcSyntax))
        }

        var childArrayCode = makeCode(for: "children",from: node)
        if childArrayCode.isEmpty {
            childArrayCode = "[]"
        }
        if childArrayCode != "[]" {
            if let parameterInfos = funcInfo?.parameterInfos {
                let positionals = parameterInfos.filter({$0.parameterLabel == "_"})
                if !positionals.isEmpty {
                    let names = positionals.map{ "\"\($0.name)\"" }
                    let s = names.count > 1 ? "s" : ""
                    let verb = names.count == 1 ? "is" : "are"
                    let namesString = names.joined(separator: ", ")
                    let issue = "Positional parameter\(s) (\(namesString)) \(verb) not allowed in parent command's command function."
                    let msg = MacroUsageDiagnosticMessage(message: issue)
                    diagnostics.append(msg.diagnostic(node: funcSyntax))
                }
            }
        }
        guard let contextCode = maybeContextCode, diagnostics.isEmpty else {
            for diagnostic in diagnostics { context.diagnose(diagnostic) }
            return []
        }
        let (code1, code2, code3) = makeCommandCode(contextCode, funcInfo!, synopsisCode, childArrayCode)
        return [DeclSyntax("\(raw: code1)"), DeclSyntax("\(raw: code2)"), DeclSyntax("\(raw: code3)")]
    }
}

/// Returns code for shadow group parameter to Contexturattion, if any. Error message is empty means all ok.
func makeCode(for name: String, from node: AttributeSyntax) -> String
{
    let synopsis = node
        .arguments?.as(LabeledExprListSyntax.self)?
        .compactMap {
            $0.label?.trimmedDescription == name ? $0.expression.trimmedDescription : nil
        }
        .first
    return synopsis ?? ""
}

/// Returns code for shadow group parameter to Contexturattion, if any. Error message is empty means all ok.
func makeCommandChildArrayCode(from node: AttributeSyntax) -> String
{
    let maybeElementList = node
        .arguments?.as(LabeledExprListSyntax.self)?
        .compactMap {
            $0.label?.trimmedDescription == "children" ? $0.expression.as(ArrayExprSyntax.self)?.elements : nil
        }
        .first
    guard let elementList = maybeElementList else {
        return "[]"
    }
    let codeList = elementList.map {$0.expression.trimmedDescription }.joined(separator: ", ")
    return "[\(codeList)]"
}

/// Ensure that funcInfo for a command macro call has a final parameter named `state` with type [T].
///
/// If funcInfo.commandType is "T", not nil, then the last parameterInfo must have name "state" and typeName "[T]" or
/// "Array<T>". Also, if funcInfo.returnType is not empty, then it must also be "[T]" or "Array<T>".
///
/// If funcInfo.commandType is nil, then no element of functInfo.parameterInfos can have name "state". Also,
/// funcInfo.returnType must be empty. If these conditions are met, a new parameterInfo named "state" with typeName
/// "[Void]" will be appended to functInfo.parameterInfos.
///
///
func ensureStateParameter(funcInfo: FuncInfo?, funcSyntax: FunctionDeclSyntax) -> (FuncInfo?, [Diagnostic])
{
    guard var newFuncInfo = funcInfo else {
        return (nil, [])
    }
    var parameterInfos = newFuncInfo.parameterInfos
    var errorMessages: [String] = []
    if let commandType = newFuncInfo.commandType {
        let stateType1 = "[\(commandType)]"
        let stateType2 = "Array<\(commandType)>"
        if let lastParameter = parameterInfos.last, lastParameter.name == "state" {
            if lastParameter.typeName != stateType1 && lastParameter.typeName != stateType2 {
                errorMessages.append("\"state\" parameter type must be an array of \(commandType).")
            }
        }
        else {
            errorMessages.append("Last parameter of must be named \"state\".")
        }
        if !newFuncInfo.returnType.isEmpty {
            if newFuncInfo.returnType != stateType1 && newFuncInfo.returnType != stateType2 {
                errorMessages.append("Return type must be an array of \(commandType).")
            }
        }
    }
    else {
        if (parameterInfos.contains{ $0.name == "state" }) {
            errorMessages.append("A \"stateless\" command function annotated by @CommandAction cannot have a parameter named \"state\".")
        }
        else if !newFuncInfo.returnType.isEmpty {
            errorMessages.append("A \"stateless\" command function annotated by @CommandAction cannot return a value.")
        }
        else {
            let stateParameterInfo = CmdFunctionParameterInfo(name: "state", typeName: "[Void]")
            parameterInfos.append(stateParameterInfo)
            newFuncInfo.parameterInfos = parameterInfos
            newFuncInfo.commandType = "Void"
            newFuncInfo.stateParameterWasSynthesized = true
        }
    }
    if !errorMessages.isEmpty {
        var diagnostics: [Diagnostic] = []
        for errorMessage in errorMessages {
            let msg = MacroUsageDiagnosticMessage(message: errorMessage)
            diagnostics.append(msg.diagnostic(node: funcSyntax))
        }
        return (funcInfo, diagnostics)
    }
    return (newFuncInfo, [])
}
