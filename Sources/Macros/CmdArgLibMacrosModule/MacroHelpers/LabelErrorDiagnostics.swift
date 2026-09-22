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

// NOTE: If you want to add default standalone label is oldStyle, must be a macrot parameter
// not parser options.


import CmdArgLibCore
import CmdArgLibMacroSupport
import SwiftSyntax
import SwiftDiagnostics
import Foundation

/// Returns
/// Allowed characters are the underscore and ascii alphanumerics
func labelErrorDiagnostics(
    _ parameterInfoNodePairs: [(CmdFunctionParameterInfo, FunctionParameterSyntax)],
    funcNode: FunctionDeclSyntax) -> [Diagnostic]
{
        func addParameterInfo(_ parameterInfo: CmdFunctionParameterInfo, label: String) {
        labelToParameterInfos[label] = (labelToParameterInfos[label] ?? []) + [parameterInfo]
    }

    var errorMsgs: [(FunctionParameterSyntax, String)] = []
    var labelToParameterInfos = [String: [CmdFunctionParameterInfo]]()
    var nameToLabelTriple: [String:String] = [:]
    if parameterInfoNodePairs.isEmpty {
        return []
    }

    for (parameterInfo, node) in parameterInfoNodePairs {
        var cmdLabels = ["nil", "nil", "nil"]
        let label = parameterInfo.parameterLabel

        if !goodName(label) {
            errorMsgs.append((node, "The label name '\(label)' is not valid (i.e., not ascii, etc.)"))
            continue
        }
        let (short, oldStyle, long) = makeLabelTriple(label)
        if let short {
            addParameterInfo(parameterInfo, label: short)
            cmdLabels[0] = "\"\(short)\""
        }
        if let oldStyle {
            addParameterInfo(parameterInfo, label: oldStyle)
            cmdLabels[1] = "\"\(oldStyle)\""
        }
        if let long {
            addParameterInfo(parameterInfo, label: long)
            cmdLabels[2] = "\"\(long)\""
        }
        let labelTriple = "(\(cmdLabels.joined(separator: ", ")))"
        nameToLabelTriple[parameterInfo.name] = labelTriple
    }
    var diagnostics = errorMsgs.map{MacroUsageDiagnosticMessage(message: $0.1).diagnostic(node: $0.0)}

    for (label, parameterInfos) in labelToParameterInfos {
        if parameterInfos.count > 1 {
            let culpritNames = parameterInfos.map { $0.name }
            let clause = culpritNames.joinedWith("and", quoteChar: "'")
            let msg = "The label '\(label)' is duplicated (used by \(clause))"
            diagnostics.append(MacroUsageDiagnosticMessage(message: msg).diagnostic(node: funcNode))
        }
    }
    return diagnostics
}

// Make sure all characters are Ascii alphanumeric, "_" or "`"
// FIXME: Perhaps relax this.
private func goodName(_ name: String) -> Bool
{
    if name.isEmpty {
        return false
    }
    let firstCharIsBacktick = name.first == "`"
    for character in name {
        if character != "_" {
            guard let c = character.asciiValue else {
                return false
            }
            if isalnum(Int32(c)) == 0 {
                if firstCharIsBacktick {
                    continue
                }
                return false
            }
        }
    }
    if firstCharIsBacktick && name.last != "`" {
        return false
    }
    return true
}
