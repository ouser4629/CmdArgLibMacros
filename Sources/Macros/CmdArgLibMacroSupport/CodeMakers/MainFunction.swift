//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import Foundation
import CmdArgLibCore

/// Used by macros
public func makeMainFunctionCode(
    _ contextCode: String,
    _ funcInfo: FuncInfoProtocol) -> (String, String, String, String)
{
    // Parameters
    let parameterInfos = funcInfo.parameterInfos
    let parameterCode = makeParametersCode(parameterInfos: parameterInfos)
    var callModifiers = funcInfo.callModifiers
    let arguments = makeMainArgumentsString(from: funcInfo, and: callModifiers)
    let returnPrefix = funcInfo.returnType.isEmpty ? "" : "return "
    let wrappedFunctionCallCode = "\(returnPrefix)\(callModifiers)\(funcInfo.name)(\(arguments))"

    var modifiers = funcInfo.modifiers
    if !modifiers.isEmpty { modifiers += " " }
    var mainReturnEffects = funcInfo.wrappedFunctionReturnEffects
    var runReturnEffects = funcInfo.wrappedFunctionReturnEffects
    if funcInfo.wrappedFunctionThrows {
        mainReturnEffects = mainReturnEffects.replacingOccurrences(of: "throws", with: "")
    }
    else {
        runReturnEffects.append(" throws")
    }
    var runFunctionCode1 = "\(modifiers)func run(with __words__: [String] = [])\(runReturnEffects)"
    var runFunctionCode2 = "\(modifiers)func run(parsing __wordsString__: String = \"\")\(runReturnEffects)"
    let mainFunctionCode = "\(modifiers)func main()\(mainReturnEffects)"

    var disregardResultCode = ""
    var returnCode = ""
    if !callModifiers.contains("try") {
        callModifiers += "try "
    }
    if !funcInfo.returnType.isEmpty {
        runFunctionCode1 += " -> \(funcInfo.returnType) "
        runFunctionCode2 += " -> \(funcInfo.returnType) "
        disregardResultCode = "let _ = "
        returnCode = "return "
    }

    // Code parts for the main() function
    let typeCheckCode = makeTypeCheckCode(parameterInfos: parameterInfos)
    let initializerBlock = initializerBlockCode(
        parameterInfos: parameterInfos, parseResultToken: "__parseResult__",
        messagesToken: "__messages__")
    let defaultValueBlock = makeDefaultValueBlock(from: parameterInfos)

    let runCode1 = """
        // Generated code could fail if a wrapped func parameter has a name like "__name__".
        // We do not use context.makeUniqueName() to fix this because we want people to be able to
        // copy and paste the generated code.
        
        /// Parse an array of command line arguments, and pass the parsed values to \(funcInfo.name).
        /// Does not catch errors thrown during parsing or by \(funcInfo.name).
        \(runFunctionCode1){
            __flagCheck__(Flag.self)
            __metaTypeCheck__(MetaFlag.self)\(typeCheckCode)
            let __callNames__ = ["\(funcInfo.callName)"]\(defaultValueBlock)
            let __context__ = makeRunContext() 
            do {
                let __parseResult__ = try ParseResult(
                    callNames: __callNames__, 
                    words: __words__, 
                    parentCommandMode: false,  
                    context: __context__)
                var __messages__ = [String]()
                __messages__ += __parseResult__.parsedErrors.map { $0.description }
               \(initializerBlock)
                if !__messages__.isEmpty { throw Exception.errors(__messages__) }
                \(wrappedFunctionCallCode)
            }
            catch Exception.error(let message) {
                let errorScreen = ErrorScreen(callNames: ["\(funcInfo.callName)"], messages: [message], context: __context__)
                throw Exception.error(errorScreen.description)
            }
            catch Exception.errors(let messages) {
                let errorScreen = ErrorScreen(callNames: ["\(funcInfo.callName)"], messages: messages, context: __context__)
                throw Exception.error(errorScreen.description)
            }
        }
        """

    let runContextCode = """
        /// Make a RunContext for \(funcInfo.name).
        \(modifiers)func makeRunContext() -> RunContext {
        \(contextCode)\(defaultValueBlock)
        \(parameterCode)
        __context__.setParameters(__parameters__)
        return __context__
        }
        """

    let runCode2 = """
        /// Parse a string containing command line arguments, and pass the parsed values to \(funcInfo.name).
        /// Does not catch errors thrown during parsing or by \(funcInfo.name).
        \(runFunctionCode2){
            \(returnCode)\(callModifiers)run(with: shellSplit(__wordsString__))
        }
        """

    let mainCode = """
        /// Parse `CommandLine.arguments`, and pass the parsed values to \(funcInfo.name).
        /// Catch and print any errors thrown during parsing or by \(funcInfo.name).
        \(mainFunctionCode) {
        do {
            let (_, words) = commandLineNameAndWords()
            \(disregardResultCode)\(callModifiers)run(with: words)
        }
        catch {
            Exception.printAndExit(for: error)
        }
        }
        """

    return (runCode1, runCode2, runContextCode, mainCode)
}
