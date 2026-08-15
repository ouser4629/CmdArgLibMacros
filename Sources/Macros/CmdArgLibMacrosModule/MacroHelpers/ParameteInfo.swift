//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibMacroSupport
import SwiftSyntax
import SwiftDiagnostics

func makeParameterInfo(_ syntax: FunctionParameterSyntax) -> (CmdFunctionParameterInfo, [Diagnostic])
{
    var typeName = syntax.type.trimmedDescription
    var parameterName = syntax.firstName.trimmedDescription
    let labelName = parameterName
    if let secondName = syntax.secondName?.trimmedDescription {
        parameterName = secondName
    }
    var errorMsgs = [String]()
    let defaultValue = syntax.defaultValue?.value.trimmedDescription ?? "nil"
    if let elementType = syntax.type.as(ArrayTypeSyntax.self)?.element.trimmedDescription {
        typeName = "Array<\(elementType)>"
    }
    else if let typeName = syntax.type.as(IdentifierTypeSyntax.self)?.trimmedDescription {
        if typeName == "Flag" &&  defaultValue == "true" {
            errorMsgs.append(
                "The parameter '\(parameterName)' has a default value of 'true', which is not allowed for flags")
        }
        if (typeName == "MetaFlag" || typeName == "MetaOption") && defaultValue == "nil" {
            errorMsgs.append(
                "The parameter '\(parameterName)', is missing its required default value")
        }
        if (typeName == "Flag" || typeName == "MetaFlag" || typeName == "MetaOption") && labelName == "_" {
            errorMsgs.append(
                "The parameter '\(parameterName)', a \(typeName), must have a label")
        }
    }
    else if syntax.type.as(OptionalTypeSyntax.self) != nil {
        if defaultValue != "nil" {
            errorMsgs.append(
                "The parameter '\(parameterName)' has a non-nil default value, which is not allowed for optional types"
            )
        }
    }
    if !(defaultValue == "[]" || defaultValue == "nil") {
        if typeName.hasPrefix("Array<")  {
            errorMsgs.append("The parameter '\(parameterName)' has a default value, other than '[]', which is not allowed for arrays")
        }
        if typeName.hasPrefix("Variadic<") {
            errorMsgs.append("The parameter '\(parameterName)' has a default value, other than '[]', which is not allowed for variadics")
        }
        if typeName == "Rest" {
            errorMsgs.append("The parameter '\(parameterName)' has a default value, other than '[]', which is not allowed for parameters with type 'Rest'")
        }
    }
    if typeName == "Rest" && labelName == "_" {
        errorMsgs.append("The parameter '\(parameterName)' must have a label. Labels are required for parameters with type 'Rest' for any 'T'")
    }

    let diagnostics = errorMsgs.map{MacroUsageDiagnosticMessage(message: $0).diagnostic(node: syntax)}
    let parameterInfo = CmdFunctionParameterInfo(
        name: parameterName,
        parameterLabel: labelName,
        typeName: typeName,
        defaultValue: syntax.defaultValue?.value.trimmedDescription)
    return (parameterInfo, diagnostics)
}
