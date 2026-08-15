//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

//@testable import CmdArgLibCore
//@testable import CmdArgLibMacroSupport
@testable import CmdArgLibMacrosModule
import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

final class MoreMainFunctionTests: XCTestCase {

    func testMainFunctionRunNoHelp() throws
    {
        assertMacroExpansion(
            """
            @MainFunctionMacro(shadowGroups: ["lower upper"])
            static func work(
                lower: Flag,
                upper: Flag,
            ) throws {
                print(tag)
            }
            """,

            expandedSource:
            """
            static func work(
                lower: Flag,
                upper: Flag,
            ) throws {
                print(tag)
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Parse an array of command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(with __words__: [String] = []) throws {
                __flagCheck__(Flag.self)
                __metaTypeCheck__(MetaFlag.self)
                let __callNames__ = ["work"]
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
                    if !__messages__.isEmpty {
                        throw Exception.errors(__messages__)
                    }
                    try work(lower: __lower__value, upper: __upper__value)
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
                let __shadowGroups__: [String] =  ["lower upper"]
                var __context__ = RunContext("work")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __parameters__: [Parameter] = [
                    Parameter("lower", "lower", "Flag", nil),
                    Parameter("upper", "upper", "Flag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }

            /// Parse a string containing command line arguments, and pass the parsed values to work.
            /// Does not catch errors thrown during parsing or by work.
            static func run(parsing __wordsString__: String = "") throws {
                try run(with: shellSplit(__wordsString__))
            }

            /// Parse `CommandLine.arguments`, and pass the parsed values to work.
            /// Catch and print any errors thrown during parsing or by work.
            static func main() {
                do {
                    let (_, words) = commandLineNameAndWords()
                    try run(with: words)
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
