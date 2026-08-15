//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibCore
import Foundation

// If the command function annotated with @CommandAction does not have a `state: [T]` parameter
// there is no need to add the state parameter to the command function call.
func makeMainArgumentsString(from funcInfo: FuncInfoProtocol, and callModifiers: String) -> String {
    var argumentClauses = [String]()
    for parameterInfo in funcInfo.parameterInfos {
        if !parameterInfo.isMeta {
            let typeGroup = TypeGroup(typeName: parameterInfo.typeName)
            var name = parameterInfo.name.trimmingBackticks
            name = "__\(name)__value"
            let argumentLabel = parameterInfo.parameterLabel
            let argumentClause = typeGroup.argumentClause(label: argumentLabel, name: name)
            argumentClauses.append(argumentClause)
        }
    }
    var arguments: String
    if argumentClauses.count > 3 {
        let spaces = String(repeating: " ", count: 12)
        arguments = "\n\(spaces)" + argumentClauses.joined(separator: ",\n\(spaces)")
    } else {
        arguments = argumentClauses.joined(separator: ", ")
    }
    return arguments
}

func makeCommandArgumentsString(from funcInfo: FuncInfoProtocol, and callModifiers: String) -> String {
    let argumentClauses = makeCommandArgumentClauses(from: funcInfo)
    var arguments: String
    if argumentClauses.count > 3 {
        let spaces = String(repeating: " ", count: 12)
        arguments = "\n\(spaces)" + argumentClauses.joined(separator: ",\n\(spaces)")
    } else {
        arguments = argumentClauses.joined(separator: ", ")
    }
    return arguments
}

func makeCommandArgumentClauses(from funcInfo: FuncInfoProtocol) -> [String] {
    var argumentClauses = [String]()
    for parameterInfo in funcInfo.parameterInfos {
        if !parameterInfo.isMeta {
            var name = parameterInfo.name.trimmingBackticks
            if name == "state" {
                if !funcInfo.stateParameterWasSynthesized {
                    argumentClauses.append("state: __state__")
                }
            } else {
                name = "__\(name)__value"
                let argumentLabel = parameterInfo.parameterLabel
                let typeGroup = TypeGroup(typeName: parameterInfo.typeName)
                let argumentClause = typeGroup.argumentClause(label: argumentLabel, name: name)
                argumentClauses.append(argumentClause)
            }
        }
    }
    return argumentClauses
}

// These are statements that declare values to be set by parser values
// No need for meta flags - the wrapper function will throw if meta flag is encountered
// and these will not be called - so they are never set to anything.

func initializerBlockCode(
    parameterInfos: [CmdFunctionParameterInfo],
    parseResultToken: String, messagesToken: String) -> String
{
    var initializerStatements = [String]()
    for parameterInfo in parameterInfos {
        let typeGroup = TypeGroup(typeName: parameterInfo.typeName)
        let name = parameterInfo.name.trimmingBackticks
        if let initializerStatement = typeGroup.initializerStatement(
            name: name, typeName: parameterInfo.typeName, messagesToken: messagesToken)
        {
            initializerStatements.append(initializerStatement.replacingOccurrences(of: "Self.", with: ""))
        }
    }
    var initializerBlock = ""
    if !initializerStatements.isEmpty {
        let initializerCode =
            " let __initializer = __ValueInitializer(parsedValues: \(parseResultToken).parsedValues)\n    "
        initializerBlock = initializerCode + initializerStatements.joined(separator: "\n    ")
    }
    return initializerBlock
}

func makeDefaultValueBlock(from parameterInfos: [CmdFunctionParameterInfo]) -> String
{
    var defaultValueStatements = [String]()
    for parameterInfo in parameterInfos {
        let typeGroup = TypeGroup(typeName: parameterInfo.typeName)
        let defaultValueStatement = typeGroup.defaultValueStatement(
            name: "__\(parameterInfo.name)__default",
            typeName: parameterInfo.typeName,
            defaultExpr: parameterInfo.defaultValue)
        if let defaultValueStatement {
            defaultValueStatements.append(defaultValueStatement)
        }
    }
    let defaultValueBlock = defaultValueStatements.joined()
    return defaultValueBlock
}

