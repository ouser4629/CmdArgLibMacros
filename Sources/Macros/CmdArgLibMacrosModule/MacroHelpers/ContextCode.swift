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
