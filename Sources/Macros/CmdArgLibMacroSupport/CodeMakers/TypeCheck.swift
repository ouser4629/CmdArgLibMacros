//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

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
