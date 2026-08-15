//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibCore

/// Used by macros
public func makeParametersCode(parameterInfos: [CmdFunctionParameterInfo]) -> String
{
    func parameterInstanceCode(_ pi: CmdFunctionParameterInfo) -> String {
        var defaultValueCode = "nil"
        let typeGroup = TypeGroup(typeName: pi.typeName)
        switch typeGroup {
        case .basicType, .variadicCmdArgLibValue, .arrayOfCmdArgLibValue, .restCmdArgLibValue:
            let defaultValueName = "__\(pi.name)__default"
            defaultValueCode = "__quotedOrNil(\(defaultValueName))"
        default:
            break
        }
        let name = pi.name.trimmingBackticks
        let label = pi.parameterLabel.trimmingBackticks
        let code = """
            Parameter("\(label)", "\(name)", "\(pi.typeName)", \(defaultValueCode))
            """
        return code
    }

    let parameterInitialers = parameterInfos.map { parameterInstanceCode($0) }
    let parametersCode = parameterInitialers.joined(separator: ",\n")
    let code = """
        let __parameters__: [Parameter] = [
        \(parametersCode)]
        """
    return code
}
