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

/// Generate a peer function that can  invoked  by the operating system with  command line parameters.
/// - Parameters:
///   - shadowGroups: Names of parameters that shadow each other (last one wins)
@attached(peer, names: named(main), named(makeRunContext), named(run))
public macro MainFunctionMacro(
    shadowGroups: [String] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "MainFunctionMacro")

/// --------------------------------------------------------------------------------------------------

/// Generate an instance of CommandNode<T>
/// - Parameters:
///   - shadowGroups: Names of parameters that shadow each other (last one wins)
///   - synopsis: Short description of what the command does
///   - children: Subcommands
///
/// The macro produces an instance of CommandNode<T> named command
/// and two peer functions:
///   1. action, which confroms to CommandNodeAction
///   2. actionContext, which returns the instance of RunContext corresponding to action
///
/// If the command function does not have state as last parameters, they will be sythesized in the
/// wrapping funcion with type T (suitable for Command<T>.
///   1. if the work funcition returns something, it  must be [T]
///   2. If the command function returns nothing, T will be Void.

@attached(peer, names: named(action), named(makeRunContext), named(commandNode))
public macro CommandNodeMacro<T>(
    shadowGroups: [String] = [],
    synopsis: String,
    children: [CommandNode<T>] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "CommandNodeMacro")

@attached(peer, names: named(action), named(makeRunContext), named(commandNode))
public macro CommandNodeMacro(
    shadowGroups: [String] = [],
    synopsis: String,
    children: [CommandNode<Void>] = []
) = #externalMacro(module: "CmdArgLibMacrosModule", type: "CommandNodeMacro")

