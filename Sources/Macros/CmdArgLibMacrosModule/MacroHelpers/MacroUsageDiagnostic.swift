//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.

import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// Used to make a diagnostic  messages and diagnostics
struct MacroUsageDiagnosticMessage: DiagnosticMessage
{
    let message: String
    let diagnosticID: SwiftDiagnostics.MessageID
    let severity: SwiftDiagnostics.DiagnosticSeverity

    init(
        message: String,
        diagnosticID: MessageID = MessageID(domain: "CmdArgLibCore", id: "MacroUsageError"),
        severity: DiagnosticSeverity = .error )
    {
        self.message = message
        self.diagnosticID = diagnosticID
        self.severity = severity
    }

    func diagnostic<Node: SyntaxProtocol>(
        node: Node,
        position: AbsolutePosition? = nil,
        highlights: [Syntax]? = nil,
        notes: [Note] = [],
        fixIts: [FixIt] = [] ) -> Diagnostic
    {
        let diagnostic = Diagnostic(
            node: node, position: position, message: self, highlights: highlights, notes: notes,
            fixIts: fixIts)
        return diagnostic
    }
}
