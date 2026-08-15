//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

@testable import CmdArgLibCore
@testable import CmdArgLibMacroSupport
@testable import CmdArgLibMacrosModule
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

enum Bug: String, CmdArgEnum { case ant, bee, dog}


final class MainFunctionMacroTests: XCTestCase {

    func testMainFunctionMacroWithRest() throws
    {
        assertMacroExpansion(
            """
            @MainFunctionMacro
            @discardableResult
            static func work(
                `flag`: Flag,
                metaFlag: MetaFlag = MetaFlag(string: "Yes sir"),
                generateCompletionScript: MetaOption<Shell> = MetaOption(completionScript),
                bugs: Variadic<Bug> = [],
                rest: Rest = []) throws -> String
            {
                print(bugs)
                return "Hi"
            }
            """,
            expandedSource: """
            @discardableResult
            static func work(
                `flag`: Flag,
                metaFlag: MetaFlag = MetaFlag(string: "Yes sir"),
                generateCompletionScript: MetaOption<Shell> = MetaOption(completionScript),
                bugs: Variadic<Bug> = [],
                rest: Rest = []) throws -> String
            {
                print(bugs)
                return "Hi"
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Parse an array of command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(with __words__: [String] = []) throws -> String {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Bug.self)
                let __callNames__ = ["work"]
                let __bugs__default: Variadic<Bug>? = []
                let __rest__default: Rest? = []
                let __context__ = makeRunContext()
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: false,
                        context: __context__)
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __flag__value: Flag = __initializer.__parseFlag(for: "flag", &__messages__)
                    let __bugs__value: Variadic<Bug>? = __initializer.__parseArrayValues(for: "bugs", __bugs__default,  &__messages__)
                    let __rest__value: Rest? = __initializer.__parseRestValues(for: "rest", __rest__default,  &__messages__)
                    if !__messages__.isEmpty {
                        throw Exception.errors(__messages__)
                    }
                    return try work(`flag`: __flag__value, bugs: __bugs__value!, rest: __rest__value!)
                }
                catch Exception.error(let message) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: [message], context: __context__)
                    throw Exception.error(errorScreen.description)
                }
                catch Exception.errors(let messages) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: messages, context: __context__)
                    throw Exception.error(errorScreen.description)
                }
            }

            /// Make a RunContext for work.
            static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("metaFlag", MetaFlag(string: "Yes sir")),
                        ("generateCompletionScript", MetaOption(completionScript))
                ]
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __bugs__default: Variadic<Bug>? = []
                let __rest__default: Rest? = []
                let __parameters__: [Parameter] = [
                    Parameter("flag", "flag", "Flag", nil),
                    Parameter("metaFlag", "metaFlag", "MetaFlag", nil),
                    Parameter("generateCompletionScript", "generateCompletionScript", "MetaOption<Shell>", nil),
                    Parameter("bugs", "bugs", "Variadic<Bug>", __quotedOrNil(__bugs__default)),
                    Parameter("rest", "rest", "Rest", __quotedOrNil(__rest__default))]
                __context__.setParameters(__parameters__)
                return __context__
            }

            /// Parse a string containing command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(parsing __wordsString__: String = "") throws -> String {
                return try run(with: shellSplit(__wordsString__))
            }

            /// Parse `CommandLine.arguments`, and pass the parsed values to work.
            /// Catch and print any errors thrown during parsing or by work.
            static func main() {
                do {
                    let (_, words) = commandLineNameAndWords()
                    let _ = try run(with: words)
                }
                catch {
                    Exception.printAndExit(for: error)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMainFunctionMacroMainWithShadowGroups() throws
    {
        assertMacroExpansion(
            """
            @MainFunctionMacro(shadowGroups: [])
            static func work(
                lower: Flag,
                upper: Flag,
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3) -> [Int]
            {
                print(tag)
                return [2]
            }
            """,
            expandedSource: """
            static func work(
                lower: Flag,
                upper: Flag,
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3) -> [Int]
            {
                print(tag)
                return [2]
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Parse an array of command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(with __words__: [String] = []) throws -> [Int] {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = ["work"]
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __context__ = makeRunContext()
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: false,
                        context: __context__)
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __lower__value: Flag = __initializer.__parseFlag(for: "lower", &__messages__)
                    let __upper__value: Flag = __initializer.__parseFlag(for: "upper", &__messages__)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        throw Exception.errors(__messages__)
                    }
                    return work(
                        lower: __lower__value,
                        upper: __upper__value,
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!)
                }
                catch Exception.error(let message) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: [message], context: __context__)
                    throw Exception.error(errorScreen.description)
                }
                catch Exception.errors(let messages) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: messages, context: __context__)
                    throw Exception.error(errorScreen.description)
                }
            }

            /// Make a RunContext for work.
            static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = []
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("lower", "lower", "Flag", nil),
                    Parameter("upper", "upper", "Flag", nil),
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default))]
                __context__.setParameters(__parameters__)
                return __context__
            }

            /// Parse a string containing command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(parsing __wordsString__: String = "") throws -> [Int] {
                return try run(with: shellSplit(__wordsString__))
            }

            /// Parse `CommandLine.arguments`, and pass the parsed values to work.
            /// Catch and print any errors thrown during parsing or by work.
            static func main() {
                do {
                    let (_, words) = commandLineNameAndWords()
                    let _ = try run(with: words)
                }
                catch {
                    Exception.printAndExit(for: error)
                }
            }
            """,
            macros: testMacros
        )
    }

    func testMainFunctionMacroMainThrowsReturnsValue() throws
    {
        assertMacroExpansion(
            """
            @MainFunctionMacro
            @discardableResult
            static func work(
                lower: Flag,
                upper: Flag,
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3) throws -> [Int]
            {
                print(tag)
                return [2]
            }
            """,
            expandedSource: """
            @discardableResult
            static func work(
                lower: Flag,
                upper: Flag,
                a__intArray intArray: [Int],
                variadics: Variadic<Double> = [],
                i__int int: Int = 3) throws -> [Int]
            {
                print(tag)
                return [2]
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Parse an array of command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(with __words__: [String] = []) throws -> [Int] {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                __typeCheck__(Double.self)
                __typeCheck__(Int.self)
                let __callNames__ = ["work"]
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __context__ = makeRunContext()
                do {
                    let __parseResult__ = try ParseResult(
                        callNames: __callNames__,
                        words: __words__,
                        parentCommandMode: false,
                        context: __context__)
                    var __messages__ = [String]()
                    __messages__ += __parseResult__.parsedErrors.map {
                        $0.description
                    }
                    let __initializer = __ValueInitializer(parsedValues: __parseResult__.parsedValues)
                    let __lower__value: Flag = __initializer.__parseFlag(for: "lower", &__messages__)
                    let __upper__value: Flag = __initializer.__parseFlag(for: "upper", &__messages__)
                    let __intArray__value: Array<Int>? = __initializer.__parseArrayValues(for: "intArray", __intArray__default, &__messages__)
                    let __variadics__value: Variadic<Double>? = __initializer.__parseArrayValues(for: "variadics", __variadics__default,  &__messages__)
                    let __int__value: Int? = __initializer.__parseValue(for: "int", __int__default, &__messages__)
                    if !__messages__.isEmpty {
                        throw Exception.errors(__messages__)
                    }
                    return try work(
                        lower: __lower__value,
                        upper: __upper__value,
                        a__intArray: __intArray__value!,
                        variadics: __variadics__value!,
                        i__int: __int__value!)
                }
                catch Exception.error(let message) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: [message], context: __context__)
                    throw Exception.error(errorScreen.description)
                }
                catch Exception.errors(let messages) {
                    let errorScreen = ErrorScreen(callNames: ["work"], messages: messages, context: __context__)
                    throw Exception.error(errorScreen.description)
                }
            }

            /// Make a RunContext for work.
            static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = []
                let __shadowGroups__: [String] = []
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __intArray__default: Array<Int>? = nil
                let __variadics__default: Variadic<Double>? = []
                let __int__default: Int? = 3
                let __parameters__: [Parameter] = [
                    Parameter("lower", "lower", "Flag", nil),
                    Parameter("upper", "upper", "Flag", nil),
                    Parameter("a__intArray", "intArray", "Array<Int>", __quotedOrNil(__intArray__default)),
                    Parameter("variadics", "variadics", "Variadic<Double>", __quotedOrNil(__variadics__default)),
                    Parameter("i__int", "int", "Int", __quotedOrNil(__int__default))]
                __context__.setParameters(__parameters__)
                return __context__
            }

            /// Parse a string containing command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(parsing __wordsString__: String = "") throws -> [Int] {
                return try run(with: shellSplit(__wordsString__))
            }

            /// Parse `CommandLine.arguments`, and pass the parsed values to work.
            /// Catch and print any errors thrown during parsing or by work.
            static func main() {
                do {
                    let (_, words) = commandLineNameAndWords()
                    let _ = try run(with: words)
                }
                catch {
                    Exception.printAndExit(for: error)
                }
            }
            """,
            macros: testMacros
        )
    }
}
