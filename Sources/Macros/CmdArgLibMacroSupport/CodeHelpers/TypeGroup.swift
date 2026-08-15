//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import CmdArgLibCore

extension TypeGroup {
    /// typeName is node typeName
    func initializerStatement(name: String,
                              typeName: String,
                              messagesToken: String) -> String?
    {
        let avn = "__\(name)__value"
        let dvn = "__\(name)__default"
        var string: String? = nil
        switch self {
        case .basicType:
            string =
                "    let \(avn): \(typeName)? = __initializer.__parseValue(for: \"\(name)\", Self.\(dvn), &\(messagesToken))"
        case .optionalCmdArgLibValue:
            string =
                "    let \(avn): \(typeName) = __initializer.__parseOptionalValue(for: \"\(name)\",  &\(messagesToken))"
        case .arrayOfCmdArgLibValue:
            string =
                "    let \(avn): \(typeName)? = __initializer.__parseArrayValues(for: \"\(name)\", Self.\(dvn), &\(messagesToken))"
        case .variadicCmdArgLibValue:
            string =
                "    let \(avn): \(typeName)? = __initializer.__parseArrayValues(for: \"\(name)\", Self.\(dvn),  &\(messagesToken))"
        case .restCmdArgLibValue:
            string =
                "    let \(avn): \(typeName)? = __initializer.__parseRestValues(for: \"\(name)\", Self.\(dvn),  &\(messagesToken))"
        case .flag:
            string = "    let \(avn): Flag = __initializer.__parseFlag(for: \"\(name)\", &\(messagesToken))"
        case .metaFlag, .metaOption:
            string = nil
        }
        return string
    }

    func callParameter(label: String, name: String) -> String
    {
        switch self {
        case .basicType:
            return "\(label): \(name)!"
        default:
            return "\(label): \(name)"
        }
    }

    func argumentClause(label: String, name: String) -> String
    {
        let labelClause = label == "_" ? "" : "\(label): "
        switch self {
        case .basicType:
            return "\(labelClause)\(name)!"
        case .arrayOfCmdArgLibValue, .variadicCmdArgLibValue, .restCmdArgLibValue:
            return "\(labelClause)\(name)!"
        default:
            return "\(labelClause)\(name)"
        }
    }

    func assignStatement(name: String) -> String
    {
        switch self {
        case .basicType:
            return "    self.\(name) = \(name)!"
        default:
            return "    self.\(name) = \(name)"
        }
    }

    func defaultValueStatement(name: String, typeName: String, defaultExpr: String?) -> String?
    {
        switch self {
        case .basicType, .variadicCmdArgLibValue, .arrayOfCmdArgLibValue, .restCmdArgLibValue:
            return "\nlet \(name): \(typeName)? = \(defaultExpr ?? "nil")"
        default:
            return nil
        }
    }

    static func elementType(of typeName: String) -> String
    {
        let typeGroup = TypeGroup(typeName: typeName)

        var valueTypeName = ""
        switch typeGroup {
        case .arrayOfCmdArgLibValue:
            valueTypeName = String(typeName.dropFirst(6).dropLast(1))
        case .variadicCmdArgLibValue:
            valueTypeName = String(typeName.dropFirst(9).dropLast(1))
        case .restCmdArgLibValue:
            valueTypeName = String(typeName.dropFirst(5).dropLast(1))
        case .optionalCmdArgLibValue:
            valueTypeName = String(typeName.dropLast(1))
        case .flag, .metaFlag:
            valueTypeName = ""
        default:
            valueTypeName = typeName
        }
        return valueTypeName
    }

}
