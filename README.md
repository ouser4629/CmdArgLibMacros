<!-- 
//  Copyright (c) 2025-2026 Peter Buenafuente Summerland.
//  All rights reserved.
//
//  This Source Code Form is subject to the terms of the Mozilla Public
//  License, v. 2.0. If a copy of the MPL was not distributed with this
//  file, You can obtain one at https://mozilla.org/MPL/2.0.
-->

## CmdArgLibMacros

CmdArgLibMacros is part of the [Command Argument Library](https://github.com/ouser4629/cmd-arg-lib.git). 

It exports two peer macros, `MainFunctionMacro` and `CommandNodeMacro`, that derive command-line interfaces
directly from annotated Swift function declarations.

The macros generate code that performs argument parsing and dispatches to the annotated function with strongly typed parameter values.

---

## MainFunctionMacro

### Usage

1. Define a struct annotated with @main.

2. Add a static [command function](https://github.com/ouser4629/cmd-arg-lib/blob/main/REFERENCE.md/#command-function) that implements program logic. 

3. Annotate the command function with '@MainFunctionMacro'. E.g.,

4. Build and run.

### Sample

This simple program prints a phrase.

<details>
<summary>Code</summary>

```swift
import CmdArgLibCore
import CmdArgLibMacros

@main
struct Main {
    @MainFunctionMacro(shadowGroups: ["u l"])
    static public func printM1(
        l: Flag,
        u: Flag,
        count: Int = 1,
        _ phrase: String) throws
    {
        guard count >= 1 else { throw Exception.error("count must be >= 1") }
        let line = u ? phrase.uppercased() : l ? phrase.lowercased() : phrase
        for _ in 1...count { print(line) }
    }
}
```

</details>

<details>
<summary>Command Calls</summary>

```
> print-m1 --count=2 "Hello world!" 
Hello world!
Hello world!

> print-m1 -lu "Hello world!"
HELLO WORLD!

> print-m1 -ul "Hello world!"
hello world!

> print-m1 -xuxxylzz --count 2.1
Errors:
  unrecognized options: "-x", "-y" and "-z", in "-xuxxylzz"
  missing value: "<phrase>"
  "2.1" is not a valid <int> after --count
See "print-m1 --help" for more information.
```

</details>

---


## CommandNodeMacro

### Usage

1. Define a state element.

2. Define a struct annotated with @main.

3. Add a static [stateful command function](https://github.com/ouser4629/cmd-arg-lib/blob/main/REFERENCE.md/#stateful-command-function) that implements program logic. 

4. Add a static list of childNodes. E.g.,

5. Annotate the stateful command function with `@CommandNodeMacro`.

6. Build and run.

### Sample

This is a hierarchical command program that prints quotes and book titles.

```
> advice-m --tree
advice-m
├── quotes
│   ├── general - print quotes about life in general
│   └── computing - print quotes about computing
└── books - print a list of recommended books
```

<details>
<summary>Top Level Code</summary>

```swift
import CmdArgLibCore
import CmdArgLibMacros

@main
struct Main {
    @CommandNodeMacro<TextStyle>(synopsis: "Print quotes and book titles.", children: childNodes)
    static func adviceM(
        u__upper upper: Flag,
        l__lower lower: Flag,
        c__color color: Color = .white,
        t__tree: MetaFlag = MetaFlag(treeFor: "advice-m", synopsis: ""),
        state: [TextStyle]) -> [TextStyle]
        {
            let textStyle = TextStyle(upper: upper, lower: lower, color: color)
            return [textStyle]
        }
    }
        
    private static let childNodes = [Quotes.commandNode, Books.commandNode,]
}
```

</details>

<details>
<summary>Quotes Level Code</summary>

```swift
iimport CmdArgLibCore
import CmdArgLibMacros

struct Quotes {
    @CommandNodeMacro<TextStyle>(synopsis: "Print quotes by famous people.", children: childNodes)
    static func quotes( state: [TextStyle]) -> [TextStyle]
    {
        return state
    }

    private static let childNodes = [GeneralQuotes.commandNode, ComputingQuotes.commandNode]
}
```

</details>

<details>
<summary>General Quotes Level Code</summary>

```swift
import CmdArgLibCore
import CmdArgLibHelpScreen

struct GeneralQuotes {
    @CommandNodeMacro<TextStyle>(synopsis: "Print quotes about life in general.")
    static func general(
        count: Count = 1,
        state: [TextStyle] ) throws
    {
        if let textStyle = state.first {
            try printCitedStringWith(textStyle, count: count, stringAuthor: generalQuotes)
        }
        return []
    }
}
```

</details>

<details>
<summary>Command Calls</summary>

```
> advice-m --upper quotes general
QUOTE
  WELL DONE IS BETTER THAN WELL SAID. - BENJAMIN FRANKLIN
  
> advice-m -uxz --color purple quotes genera
Errors:
  unrecognized options: "-x" and "-z", in "-uxz"
  "purple" is not a valid <color> after --color
See "advice-m --help" for more information.
```

```
> advice-m -u --color yellow quotes genera
Error:
  unrecognized subcommand: "genera"
```

</details>

---

## Concepts

A command function declares the parameters used to implement the program's logic.

Each parameter declaration provides the information needed to define a corresponding CLI argument.

* label - acts as a "label-spec", e.g., "c__count" -> "-c" and "--count"
* name - for use in the command function
* type - determines how the argument is parsed
* default value – determines whether the argument is required and, if not, its default value

A macro that annotates a command function declaration can generate code that defines
a CLI whose arguments correspond one-to-one with the arguments of the annotated function.

Command-line arguments are essentially limited to strings, integers, floating-point values, and flags (switches).
Accordingly, it is appropriate to limit the "basic" types of the parameters
to `String`, `Int`, `Double`, and string-backed enums. Other supported types should include `Flag`, `Array<B>`, 
`Optional<B>` and `Variadic<B>`, where `B` is a basic type. 

The CLI defined by the macro should, to the extent possible, mimic Swift, yet feel natural to 
shell users.

The macro should have as few arguments as possible, and parsing semantics should be fixed and predictable.

---

## Examples

[Command Argument Library](https://github.com/ouser4629/cmd-arg-lib.git) has extensive examples
that show how to use `CmdArgLibMacros`.

---

## Project Status

This software is licensed under the [Mozilla Public License, v. 2.0 "MPL-2.0"](https://mozilla.org/MPL/2.0).

It is currently in beta (version 0.5.0), and has only been tested for macOS.

