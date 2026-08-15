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

func makeContextCode(
    _ funcInfo: FuncInfo,
    _ node: AttributeSyntax ) -> (code: String?, errors: [Diagnostic])
{
    let parameterInfos = funcInfo.parameterInfos
    let parameterNames = parameterInfos.map { $0.name }

    let contextCode = "RunContext(\"\(funcInfo.callName)\")"
    let (shadowGroupsCode, shadowGroupsErrors) = makeShadowGroupsCode(from: node, parameterNames: parameterNames)
    let metaTypesCode = makeMetaTypesCode(from: parameterInfos)
    if !shadowGroupsErrors.isEmpty { return (nil, shadowGroupsErrors) }

    let code = """
        \(metaTypesCode)
        let __shadowGroups__: [String] = \(shadowGroupsCode)
        var __context__ = \(contextCode)
        __context__.__addShadowGroups(__shadowGroups__)
        __context__.__setMetaTypes(__metaTypeDefs__)
        """
    return (code, [])
}

func makeMetaTypesCode(from parameterInfos: [CmdFunctionParameterInfo]) -> (String)
{
    var metaTypeDefs: [String] = []
    for p in parameterInfos {
        if p.typeName.hasPrefix("Meta") {
            if let defaultValue = p.defaultValue {
                let nameFunc = "(\"\(p.name)\", \(defaultValue))"
                metaTypeDefs.append(nameFunc)
            }
        }
    }
    var code = """
        let __metaTypeDefs__: [(String, MetaType)] = [
                \(metaTypeDefs.joined(separator: ",\n        "))
        ]
        """
    if metaTypeDefs.isEmpty {
        code = "let __metaTypeDefs__: [(String, MetaType)] = []"
    }
    return code
}

/// Returns code for shadow group parameter to Contexturattion, if any. Error message is empty means all ok.
func makeShadowGroupsCode(from node: AttributeSyntax, parameterNames: [String]) -> (String, [Diagnostic])
{
    let maybeElementListSyntax = node
        .arguments?.as(LabeledExprListSyntax.self)?
        .compactMap {
            $0.label?.trimmedDescription == "shadowGroups" ? $0.expression.as(ArrayExprSyntax.self)?.elements : nil
        }
        .first
    guard let elementList = maybeElementListSyntax else {
        return ("[]", [])
    }
    let syntaxOk = elementList.allSatisfy { $0.expression.as(StringLiteralExprSyntax.self) != nil }

    if !syntaxOk {
        let message = MacroUsageDiagnosticMessage(message: "All shadowGroups arguments must be string literals.")
        return ("", [message.diagnostic(node: node)])
    }

    let groupSpecs =
        elementList
        .map {
            $0.expression.as(StringLiteralExprSyntax.self)!
                .trimmedDescription.replacingOccurrences(of: "\"", with: "")
        }
    let goodNames: Set<String> = Set(parameterNames)
    var badNames: Set<String> = []
    var groups: [[String]] = []
    for groupSpec in groupSpecs {
        var groupElements: [String] = []
        for name in groupSpec.components(separatedBy: .whitespaces) {
            if goodNames.contains(name) {
                groupElements.append(name)
            } else {
                badNames.insert(name)
            }
        }
        groups.append(groupElements)
    }
    if !badNames.isEmpty {
        let badNamesAsString = badNames.sorted().joinedWith("and", quoteChar: "'", separator: ",")
        let name = badNames.count == 1 ? "name" : "names"
        let message = MacroUsageDiagnosticMessage(
            message: "Unrecognized shadowed parameter \(name): \(badNamesAsString).")
        return ("", [message.diagnostic(node: node)])
    }
    if groups.isEmpty {
        return ("[]", [])
    }
    let groupStrings = groups.map { $0.joined(separator: " ") }
    let code = " \(groupStrings.debugDescription)"
    return (code, [])
}
