# zed-raku

[Raku](https://raku.org) language support for the [Zed](https://zed.dev)
editor: tree-sitter syntax highlighting, indentation, bracket matching, an
outline, text objects, and optional
[Raku Navigator](https://github.com/bscan/RakuNavigator) LSP integration.

> **Experimental / work in progress.** This is a personal project, not published
> to the Zed extension registry. The grammar is a Perl grammar with hand-added
> Raku support, so some Raku-only syntax still mis-highlights or errors (see
> [Known gaps](#known-gaps)). Expect breakage.

## What works

Language features: syntax highlighting, auto-indent, bracket matching, code
outline, text objects, and embedded POD (via a separate `POD` language).

File set: `raku`, `rakumod`, `rakutest`, `rakudoc`, `p6`, `pl6`, `pm6`, `t6`,
`pod6`, `nqp` (plus a first-line shebang pattern for `raku`/`perl6`).

Raku constructs the grammar understands today:

- **Variables**: sigils, twigils (`$!x`, `$.x`, `$?x`, `$^x`, `$*x`, `@.list`,
  `%!map`), sigilless variables (`my \x`), chained subscripts (`@a[0][1]`,
  `%h<a><b>`), angle subscripts (`%h<key>`).
- **Declarators**: `my`/`our`/`state`, `has` attributes (with types, `is`/`does`/
  `handles` traits, defaults), `constant`, `subset`, `enum`, `class`/`role`/
  `grammar`/`module`/`package` (including parameterised `role R[::T]` and
  inheritance traits `is`/`does`).
- **Subs & methods**: typed signatures (`Int $x`, `:$named`, slurpy `*@a`,
  `$x?`/`$x!`, `where`, `is rw`), return types (`--> T` inside the signature,
  `of`/`returns T` outside), `multi`/`proto`/`only`, private/meta methods
  (`method !x`, `method ^x`), `submethod`, user-defined operators
  (`sub infix:<+>`, `prefix:`, `postfix:`, `circumfix:`, `term:`).
- **Expressions**: Raku `.method(...)` / `.method: args` calls, safe/meta calls
  (`.?`, `.^`, `.&`, `.!`), named arguments (`:name`, `:name(...)`,
  `:name<...>`, `:$var`, `:!name`), the Whatever star (`*`), pointy blocks and
  pointy `for @a -> $x { ... }`, junctions-as-bitwise (`|`/`&`/`^`), `?? !!`
  ternary, `but` (with anonymous roles), reduction (`[+]`), zip/cross
  (`Z`/`X`/`Z+`), hyper (`>>+<<`, `»*«`, `@a>>.uc`) metaoperators.
- **Control flow**: paren-less `if`/`elsif`/`unless`/`while`/`until`/`for`
  (and the parenthesised forms), `given`/`when`/`default`.
- **Literals**: strings (`q`, `qq`, `Q`, single/double quotes, `<<>>`/`{}`
  delimiters), `rx`/`m`/`s`/`tr` regexes, number literals (`0x`, `0o`, `0b`,
  `0d`, `:16<ff>`), `1..10` ranges.
- **Phasers**: `BEGIN`, `CHECK`, `INIT`, `END`, `UNITCHECK`, `ENTER`, `LEAVE`,
  `KEEP`, `UNDO`, `FIRST`, `LAST`, `NEXT`, `PRE`, `POST`, `CATCH`, `CONTROL`,
  `COMPOSE`, `START`.
- **Grammars**: `grammar`/`token`/`rule`/`regex` declarations (bodies parsed
  opaquely, not as regexes).
- **POD**: `=begin pod`/`=end pod` (nesting-aware) and `=pod`/`=cut`.

## Grammar fork

Zed compiles a grammar's generated `src/parser.c`; it does **not** run
`tree-sitter generate`. The upstream
[`acrion/tree-sitter-raku`](https://github.com/acrion/tree-sitter-raku) does not
commit `parser.c`, so this extension uses a fork that does:
[`justaperlhacker/tree-sitter-raku`](https://github.com/justaperlhacker/tree-sitter-raku).
The pinned revision lives in `extension.toml`; `scripts/build-grammar.sh`
regenerates and pushes the parser, then updates the pinned rev.

### Changes on top of upstream

All of the following were added to the fork (each verified against the grammar's
own Perl test suite with no new failures):

- `~` binary string-concat operator (upstream had only unary `~`).
- `multi`/`proto`/`only` declarators.
- Typed signature params, defaults, named/slurpy params, `where` constraints,
  `is` traits, `?`/`!` markers; return types (`--> T` inside the signature,
  `of`/`returns T` outside — matching Rakudo).
- `given`/`when`/`default`.
- Twigils and `has` attribute declarations.
- POD scanner terminates at `=end` (nesting-aware).
- `constant`/`subset`, the Whatever star, pointy `for`, angle subscripts.
- Raku `.method(...)` / `.method: args` calls; `.` removed from the Perl concat
  operators and number literals require digits after `.` (fixes `1..10` ranges).
- Paren-less `if`/`elsif`/`unless`/`while`/`until`/`for` conditions.
- `is`/`does`/`handles` traits; safe/meta method calls; named arguments;
  sigilless variables.
- Raku `?? !!` ternary.
- The full set of Raku phasers.
- User-defined operator definitions; parameterised roles/classes.
- Reduction, zip/cross and hyper metaoperators; hyper method calls.
- `but` operator and anonymous roles.
- Private/meta methods and `submethod`.
- `grammar`/`token`/`rule`/`regex` declarations.
- Raku compound assignment operators (`~=`, `max=`, `min=`, `Z=`, `X=`).
- Number literals `0o17`, `0d10`, radix `:16<ff>`.
- Chained subscripts and the `Q` quote operator.

The fork's `grammar.js` is the source of truth; `src/parser.c` is generated and
committed because Zed needs it. (It is currently ~55 MB — GitHub warns above
50 MB — a consequence of supporting Raku on a Perl grammar. See
`.plans/zed-raku-extension.plan` for the full history.)

## Known gaps

- **`q:to/END/` heredocs** — only Perl's `<<DELIM` form is supported.
- **Quote adverbs / unicode delimiters** — `q:!c{...}`, `Q:q{...}`, `q«...»`.
- **Junctions** — `1 | 2` parses as a bitwise op, so it gets an operator
  highlight rather than a junction-specific one (visually similar).
- **`token`/`rule`/`regex` bodies** are opaque (not highlighted as regexes).

## Installing as a dev extension

1. Make sure Rust is available (via [rustup](https://rustup.rs) is easiest, so
   that Zed can add the `wasm32-wasip2` target automatically).
2. In Zed, run the `zed: install dev extension` action and select this
   directory.

Make sure any `file_types` mapping in your Zed settings that routes
`.raku`/`.rakumod`/etc. to Perl is removed, so this extension claims them.

## Language server (optional)

[Raku Navigator](https://github.com/bscan/RakuNavigator) is not published to
npm, so this extension does not install it for you. Build it yourself:

```sh
git clone https://github.com/bscan/RakuNavigator
cd RakuNavigator
npm install
npm run compile
```

Then either put a `raku-navigator` executable on your `PATH` (the extension
finds it automatically), or point the extension at the compiled server:

```json
{
  "lsp": {
    "raku-navigator": {
      "settings": {
        "path": "/absolute/path/to/RakuNavigator/server/out/server.js"
      }
    }
  }
}
```

The `path` is used by the extension to locate the server; all other keys under
`settings` are passed through to the server as workspace configuration (e.g.
`rakuPath`, `includePaths`).

## Attribution

- Grammar based on [`tree-sitter-perl`](https://github.com/tree-sitter/tree-sitter-perl)
  and [`acrion/tree-sitter-raku`](https://github.com/acrion/tree-sitter-raku)
  (MIT).
- POD grammar: [`tree-sitter-perl/tree-sitter-pod`](https://github.com/tree-sitter-perl/tree-sitter-pod)
  (Artistic License 2.0).
- Queries adapted from [`tree-sitter-perl/zed-perl`](https://github.com/tree-sitter-perl/zed-perl)
  (MIT).

## License

MIT. See [LICENSE](LICENSE).
