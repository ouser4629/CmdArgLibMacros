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

/// The code is "" or full code with "\n" tagged on front
func makeTypeCheckCode(parameterInfos: [CmdFunctionParameterInfo]) -> String
{
    var valueTypeNames = Set<String>()
    for parameterInfo in parameterInfos {
        if parameterInfo.isMeta || parameterInfo.typeName == "Rest" {
            continue
        }
        let valueTypeName = TypeGroup.elementType(of: parameterInfo.typeName)
        if !valueTypeName.isEmpty {
            valueTypeNames.insert(valueTypeName)
        }
    }
    var code = ""

    if !valueTypeNames.isEmpty {
        let sortedValueTypeNames = Array(valueTypeNames).sorted()
        let typeChecks = sortedValueTypeNames.map { "__typeCheck__(\($0).self)" }.joined(separator: "\n")
        code = " \n\(typeChecks) "
    }
    return code
}
