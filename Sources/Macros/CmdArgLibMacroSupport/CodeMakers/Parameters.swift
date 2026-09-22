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
