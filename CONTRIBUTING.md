# Luau

Luau in this repository is for IDE and writing convenience. Scribunto only accepts Lua 5.1.5, so all outputs will overall end up being that instead.

For a better writing experience, you can use:

* Luau types (as much as possible, they're all stripped in the end output)
* Some function annotations/declarations like @deprecated
* String interpolation (e.g., `String with a {variable} inserted`)
* Other features stripped by Darklua

## Why Luau?

Some people may believe that Luau is Roblox-specific and can only be used in Roblox. While Luau is both developed by Roblox and most commonly applied to that use case, many programmers have built tooling around Luau because of its worthwhile benefits over vanilla Lua. In this case, Luau is not used directly, as Scribunto and MediaWiki do not support it. Instead, here, Luau is transpiled to Lua via the automated production CI pipeline (WikiWire & DarkLua) and patched with the necessary polyfills and compatibility scripts to function correctly.

With this, Luau offers significant advantages such as modern Lua features, typing, and the Luau language server protocol (Luau-LSP).

# Standards

Some standards from the OW Standards repo apply here: https://github.com/obbywiki/standards.