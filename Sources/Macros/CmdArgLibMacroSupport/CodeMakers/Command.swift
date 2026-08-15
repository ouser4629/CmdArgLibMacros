//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation
import CmdArgLibCore

/// Used by macros
public func makeCommandCode(
    _ contextCode: String,
    _ funcInfo: FuncInfoProtocol,
    _ synopsisCode: String,
    _ childArrayCode: String) -> (String, String, String)
{
    // Parameters
    let parameterInfos = Array(funcInfo.parameterInfos.dropLast(1))
    let parameterCode = makeParametersCode(parameterInfos: parameterInfos)

    // Wrapped function call
    let callModifiers = funcInfo.callModifiers
    let arguments = makeCommandArgumentsString(from: funcInfo, and: callModifiers)
    let wrappedFunctionCallCode =
        "\(funcInfo.returnType.isEmpty ? "" : "__newState__ = ")\(callModifiers)\(funcInfo.name)(\(arguments))"

    // Command action signature
    let modifiers = funcInfo.modifiers
    let nodeModifiers = modifiers.isEmpty ? "" : "\(modifiers) " 
    var funcModifiers = modifiers.replacingOccurrences(of: "public", with: "private")
    funcModifiers = funcModifiers.replacingOccurrences(of: "internal", with: "private")
    if !funcModifiers.contains("private") { funcModifiers = "private \(funcModifiers)" }
    guard let stateType = funcInfo.commandType else {
        fatalError()
    }
    var effects = funcInfo.wrappedFunctionReturnEffects
    if !effects.contains("throws") {
        effects.append(" throws")
    }
    let returnClause = " \(effects) -> ([\(stateType)], [String])".trimmingCharacters(in: .whitespaces)
    var newStateCode = ""
    var returnCode = "return ([], __trailingWords__)"
    if !funcInfo.returnType.isEmpty {
        newStateCode = "\nvar __newState__: [\(stateType)] = []"
        returnCode = "return (__newState__, __trailingWords__)"
    }
    var actionSignature = "@Sendable\n@discardableResult\n\(funcModifiers) func action(\n"
    actionSignature += "words __words__: [String],\n"
    actionSignature += "state __state__: [\(stateType)] = [],\n"
    actionSignature += "commandPath __nodePath__: [CommandNode<\(stateType)>], __context__: RunContext)"
    actionSignature += " \(returnClause)"

    // Code parts for the command action
    let typeCheckCode = makeTypeCheckCode(parameterInfos: parameterInfos)
    let initializerBlock = initializerBlockCode(
        parameterInfos: parameterInfos, parseResultToken: "__parseResult__",
        messagesToken: "__messages__")
    let defaultValueBlock = makeDefaultValueBlock(from: parameterInfos)

    let commandCode = """
    // Generated code could fail if a wrapped func parameter has a name like "__name__".
    // We do not use context.makeUniqueName() to fix this because we want people to be able to
    // copy and paste the generated code.
    
    /// Set `commandNode`
    \(nodeModifiers)let commandNode = CommandNode<\(funcInfo.commandType ?? "")>(
        name: "\(funcInfo.callName)",
        synopsis: \(synopsisCode),
        action: action,
        runContextMaker: makeRunContext,
        children: \(childArrayCode)
    )
    """

    let actionCode = """
        \(actionSignature)
        {
            __flagCheck__(Flag.self)
            __metaTypeCheck__(MetaFlag.self)\(typeCheckCode)
            let __callNames__ = __nodePath__.map{ $0.name }\(defaultValueBlock)
            var __trailingWords__ = [String]()\(newStateCode)
            do {
                let __parseResult__ = try ParseResult(
                    callNames: __callNames__, 
                    words: __words__, 
                    parentCommandMode: !__nodePath__.last!.__children__.isEmpty,
                    context: __context__)
                __trailingWords__ = __parseResult__.trailingWords
                var __messages__ = [String]()
                __messages__ += __parseResult__.parsedErrors.map { $0.description }
               \(initializerBlock)
                if !__messages__.isEmpty {
                    let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                    throw Exception.stderr(errorScreen.description) 
                }
                \(wrappedFunctionCallCode)
            }
        \(returnCode)
        }
        """

    let commandContextCode = """
        \(funcModifiers) func makeRunContext() -> RunContext {
        \(contextCode)\(defaultValueBlock)
        \(parameterCode)
        __context__.setParameters(__parameters__)
        return __context__
        }
        """

    return (commandCode, actionCode, commandContextCode)
}
