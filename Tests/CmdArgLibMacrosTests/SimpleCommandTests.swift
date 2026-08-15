//  Copyright (c) 2025-2026 Psummerland2 LLC.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.e.

import SwiftSyntaxMacrosTestSupport
import XCTest


final class SimpleCommandTests: XCTestCase {

    func testCommandVoid() throws
    {
        assertMacroExpansion(
            """
            @CommandNodeMacro(shadowGroups: ["lower upper"], synopsis: "Test", children: childArray )
            static func `init`(
                l lower: Flag,
                u upper: Flag = false,
                g__greeting greeting: Greeting = "Hello",
                h__help help: MetaFlag = Word(helpElements: helpElements)
            ) {
                let count = repeats == nil || repeats! < 1 ? (Int.random(in: 1...3)) : repeats!
                text = lower ? text.lowercased() : upper ? text.uppercased() : text
                for index in 1...count {
                    print("Hello")
                }
            }
            """,
            expandedSource: """
            static func `init`(
                l lower: Flag,
                u upper: Flag = false,
                g__greeting greeting: Greeting = "Hello",
                h__help help: MetaFlag = Word(helpElements: helpElements)
            ) {
                let count = repeats == nil || repeats! < 1 ? (Int.random(in: 1...3)) : repeats!
                text = lower ? text.lowercased() : upper ? text.uppercased() : text
                for index in 1...count {
                    print("Hello")
                }
            }

            // Generated code could fail if a wrapped func parameter has a name like "__name__".
            // We do not use context.makeUniqueName() to fix this because we want people to be able to
            // copy and paste the generated code.

            /// Set `commandNode`
            static let commandNode = CommandNode<Void>(
                name: "init",
                synopsis: "Test",
                action: action,
                runContextMaker: makeRunContext,
                children: childArray
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
                __typeCheck__(Greeting.self)
                let __callNames__ = __nodePath__.map {
                    $0.name
                }
                let __greeting__default: Greeting? = "Hello"
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
                    let __lower__value: Flag = __initializer.__parseFlag(for: "lower", &__messages__)
                    let __upper__value: Flag = __initializer.__parseFlag(for: "upper", &__messages__)
                    let __greeting__value: Greeting? = __initializer.__parseValue(for: "greeting", __greeting__default, &__messages__)
                    if !__messages__.isEmpty {
                        let errorScreen = ErrorScreen(callNames: __callNames__, messages: __messages__, context: __context__)
                        throw Exception.stderr(errorScreen.description)
                    }
                    `init`(l: __lower__value, u: __upper__value, g__greeting: __greeting__value!)
                }
                return ([], __trailingWords__)
            }

            private static func makeRunContext() -> RunContext {
                let __metaTypeDefs__: [(String, MetaType)] = [
                        ("help", Word(helpElements: helpElements))
                ]
                let __shadowGroups__: [String] =  ["lower upper"]
                var __context__ = RunContext("init")
                __context__.__addShadowGroups(__shadowGroups__)
                __context__.__setMetaTypes(__metaTypeDefs__)
                let __greeting__default: Greeting? = "Hello"
                let __parameters__: [Parameter] = [
                    Parameter("l", "lower", "Flag", nil),
                    Parameter("u", "upper", "Flag", nil),
                    Parameter("g__greeting", "greeting", "Greeting", __quotedOrNil(__greeting__default)),
                    Parameter("h__help", "help", "MetaFlag", nil)]
                __context__.setParameters(__parameters__)
                return __context__
            }

            """,
            macros: testMacros
        )
    }
}
