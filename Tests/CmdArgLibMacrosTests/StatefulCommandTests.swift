//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.e.

import SwiftSyntaxMacrosTestSupport
import XCTest

final class CommandNodeTests: XCTestCase {

    func testCommandState() throws
    {
        assertMacroExpansion(
            """
            @CommandNodeMacro<String>(synopsis: "Do something")
            public static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) -> [String] 
            { 
                return state 
            }
            """,
            expandedSource: """
            public static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) -> [String] 
            { 
                return state 
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Set `commandNode`
            public static let commandNode = CommandNode<String>(
                name: "work",
                synopsis: "Do something",
                action: action,
                runContextMaker: makeRunContext,
                children: []
            )

            @Sendable
            @discardableResult
            private static func action(
                words __words__: [String],
                state __state__: [String] = [],
                commandPath __nodePath__: [CommandNode<String>], __context__: RunContext) throws -> ([String], [String])
            {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = __nodePath__.map {
                    $0.name
                }
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                var __trailingWords__ = [String]()
                var __newState__: [String] = []
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: !__nodePath__.last!.__children__.isEmpty,
                        context: __context__)
                    __trailingWords__ = __parseResult__.trailingWords
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                        throw Exception.stderr(errorScreen.description)
                    }
                    __newState__ = work(
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!,
                        state: __state__)
                }
                return (__newState__, __trailingWords__)
            }

            private static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("help", MetaFlag(helpElements: help))
                ]
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default)),
                    Parameter("help", "help", "MetaFlag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }
            """,
            macros: testMacros
        )
    }

    func testCommandStateNoReturn() throws
    {
        assertMacroExpansion(
            """
            @CommandNodeMacro<String>(synopsis: "Do something.")
            internal static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) throws
            { 
                print(int)
            }
            """,
            expandedSource: """
            internal static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) throws
            { 
                print(int)
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Set `commandNode`
            internal static let commandNode = CommandNode<String>(
                name: "work",
                synopsis: "Do something.",
                action: action,
                runContextMaker: makeRunContext,
                children: []
            )

            @Sendable
            @discardableResult
            private static func action(
                words __words__: [String],
                state __state__: [String] = [],
                commandPath __nodePath__: [CommandNode<String>], __context__: RunContext) throws -> ([String], [String])
            {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = __nodePath__.map {
                    $0.name
                }
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                var __trailingWords__ = [String]()
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: !__nodePath__.last!.__children__.isEmpty,
                        context: __context__)
                    __trailingWords__ = __parseResult__.trailingWords
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                        throw Exception.stderr(errorScreen.description)
                    }
                    try work(
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!,
                        state: __state__)
                }
                return ([], __trailingWords__)
            }

            private static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("help", MetaFlag(helpElements: help))
                ]
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default)),
                    Parameter("help", "help", "MetaFlag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }
            """,
            macros: testMacros
        )
    }


    func testCommandStateThrows() throws
    {
        assertMacroExpansion(
            """
            @CommandNodeMacro<String>(synopsis: "Do something.")
            static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) throws -> [String] 
            { 
                return state 
            }
            """,
            expandedSource: """
            static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [String]) throws -> [String] 
            { 
                return state 
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Set `commandNode`
            static let commandNode = CommandNode<String>(
                name: "work",
                synopsis: "Do something.",
                action: action,
                runContextMaker: makeRunContext,
                children: []
            )

            @Sendable
            @discardableResult
            private static func action(
                words __words__: [String],
                state __state__: [String] = [],
                commandPath __nodePath__: [CommandNode<String>], __context__: RunContext) throws -> ([String], [String])
            {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = __nodePath__.map {
                    $0.name
                }
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                var __trailingWords__ = [String]()
                var __newState__: [String] = []
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: !__nodePath__.last!.__children__.isEmpty,
                        context: __context__)
                    __trailingWords__ = __parseResult__.trailingWords
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                        throw Exception.stderr(errorScreen.description)
                    }
                    __newState__ = try work(
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!,
                        state: __state__)
                }
                return (__newState__, __trailingWords__)
            }

            private static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("help", MetaFlag(helpElements: help))
                ]
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default)),
                    Parameter("help", "help", "MetaFlag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }
            """,
            macros: testMacros
        )
    }

    func testCommandVoidStateThrows() throws
    {
        assertMacroExpansion(
            """
            @CommandNodeMacro<Void>(synopsis: "Do something.")
            static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [Void]) throws -> [Void] 
            { 
                return state 
            }
            """,
            expandedSource: """
            static func work(
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3,
                help: MetaFlag = MetaFlag(helpElements: help),
                state: [Void]) throws -> [Void] 
            { 
                return state 
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Set `commandNode`
            static let commandNode = CommandNode<Void>(
                name: "work",
                synopsis: "Do something.",
                action: action,
                runContextMaker: makeRunContext,
                children: []
            )

            @Sendable
            @discardableResult
            private static func action(
                words __words__: [String],
                state __state__: [Void] = [],
                commandPath __nodePath__: [CommandNode<Void>], __context__: RunContext) throws -> ([Void], [String])
            {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = __nodePath__.map {
                    $0.name
                }
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                var __trailingWords__ = [String]()
                var __newState__: [Void] = []
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: !__nodePath__.last!.__children__.isEmpty,
                        context: __context__)
                    __trailingWords__ = __parseResult__.trailingWords
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                        throw Exception.stderr(errorScreen.description)
                    }
                    __newState__ = try work(
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!,
                        state: __state__)
                }
                return (__newState__, __trailingWords__)
            }

            private static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("help", MetaFlag(helpElements: help))
                ]
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default)),
                    Parameter("help", "help", "MetaFlag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }

            """,
            macros: testMacros
        )
    }
}
