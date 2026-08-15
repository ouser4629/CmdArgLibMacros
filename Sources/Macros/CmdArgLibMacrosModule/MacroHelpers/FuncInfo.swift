//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibCore
import CmdArgLibMacroSupport
import SwiftDiagnostics
import SwiftSyntax
import Foundation

struct FuncInfo: FuncInfoProtocol {
    let name: String
    let callName: String
    let genericParameterClause: String
    let modifiers: String
    let wrappedFunctionReturnEffects: String
    let returnPrefix: String
    let callModifiers: String  // e.g., try await
    let wrappedFunctionThrows: Bool
    var returnType: String
    var parameterInfos: [CmdFunctionParameterInfo]
    var commandType: String?
    var stateParameterWasSynthesized: Bool

    init(
        name: String, callName: String, genericParameterClause: String, modifiers: String,
        wrappedFunctionReturnEffects: String,
        returnType: String, returnPrefix: String, callModifiers: String, wrappedFunctionThrows: Bool,
        parameterInfos: [CmdFunctionParameterInfo], commandType: String? = nil, stateParameterWasSynthesized: Bool
    ) {
        self.name = name
        self.callName = callName
        self.genericParameterClause = genericParameterClause
        self.modifiers = modifiers
        self.wrappedFunctionReturnEffects = wrappedFunctionReturnEffects
        self.returnPrefix = returnPrefix
        self.callModifiers = callModifiers
        self.wrappedFunctionThrows = wrappedFunctionThrows
        self.returnType = returnType
        self.parameterInfos = parameterInfos
        self.commandType = commandType
        self.stateParameterWasSynthesized = stateParameterWasSynthesized
    }
}

func makeFuncInfo(funcSyntax: FunctionDeclSyntax) -> (FuncInfo, [Diagnostic])
{
    var diagnostics: [Diagnostic] = []
    let modifiers = funcSyntax.modifiers.trimmedDescription
    let name = funcSyntax.name.trimmedDescription
    var callName = SymbolFormatter.snake(name, "-")
    callName = callName.trimmingCharacters(in: CharacterSet(charactersIn: "`"))
    let signature = funcSyntax.signature
    let wrappedFunctionEffects = signature.effectSpecifiers?.trimmedDescription ?? ""
    let genericParameterClause = funcSyntax.genericParameterClause?.trimmedDescription ?? ""
    let parameterListSyntax = signature.parameterClause.parameters
    var parameterInfos: [CmdFunctionParameterInfo] = []
    var parameterInfoNodePairs: [(CmdFunctionParameterInfo, FunctionParameterSyntax)] = []
    for parameterSyntax in parameterListSyntax {
        let (parameterInfo, diagnostic) = makeParameterInfo(parameterSyntax)
        parameterInfos.append(parameterInfo)
        parameterInfoNodePairs.append((parameterInfo, parameterSyntax))
        diagnostics.append(contentsOf: diagnostic)
    }
    if name.hasPrefix("__") && name.hasSuffix("__a") {
        let message = #"Wrapped function names starting with "__" cannot end with "__""#
        diagnostics.append(MacroUsageDiagnosticMessage(message: message).diagnostic(node: funcSyntax))
    }
    diagnostics += labelErrorDiagnostics(parameterInfoNodePairs, funcNode: funcSyntax)

    let commandType = funcSyntax.attributes
        .compactMap {
            if let attributeName = $0.as(AttributeSyntax.self)?.attributeName  {
                let idType = attributeName.as(IdentifierTypeSyntax.self)
                let name = idType?.name.trimmedDescription
                if name == "CommandNodeMacro" {
                    let typeName = idType?.genericArgumentClause?.arguments.first?.argument.as(IdentifierTypeSyntax.self)?.name.trimmedDescription
                    return typeName
                }
            }
            return nil
        }.first

    var mainFuntionReturnEffects = wrappedFunctionEffects  // e.g., async - but never throws
    var callFunctionReturnEffects = wrappedFunctionEffects  // always throws
    callFunctionReturnEffects = callFunctionReturnEffects.trimmingCharacters(in: .whitespaces)
    mainFuntionReturnEffects = mainFuntionReturnEffects.trimmingCharacters(in: .whitespaces)
    if !callFunctionReturnEffects.isEmpty {
        callFunctionReturnEffects = " " + callFunctionReturnEffects
    }
    if !mainFuntionReturnEffects.isEmpty {
        mainFuntionReturnEffects = " " + mainFuntionReturnEffects
    }
    var returnType = signature.returnClause?.type.trimmedDescription ?? ""
    if returnType == "Void" { returnType = "" }
    let returnPrefix = returnType.isEmpty ? "" : "newState__CommandArgumentLibrary = "
    var callModifiers = ""
    if wrappedFunctionEffects.contains("throws") {
        callModifiers += "try "
    }
    if wrappedFunctionEffects.contains("async") {
        callModifiers += "await "
    }

    let funcInfo = FuncInfo(
        name: name,
        callName: callName,
        genericParameterClause: genericParameterClause,
        modifiers: modifiers,
        wrappedFunctionReturnEffects: wrappedFunctionEffects,
        returnType: returnType,
        returnPrefix: returnPrefix,
        callModifiers: callModifiers,
        wrappedFunctionThrows: wrappedFunctionEffects.contains("throws"),
        parameterInfos: parameterInfos,
        commandType: commandType,
        stateParameterWasSynthesized: false,
    )
    return (funcInfo, diagnostics)
}
