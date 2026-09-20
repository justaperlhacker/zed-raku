# zed-raku

[Raku](https://raku.org) language support for the [Zed](https://zed.dev)
editor: tree-sitter syntax highlighting, indentation, bracket matching, an
outline, text objects, and optional
[Raku Navigator](https://github.com/bscan/RakuNavigator) LSP integration.

## Status

Early. The grammar (`acrion/tree-sitter-raku`) is a lightly modified Perl
grammar, so Raku-only syntax (`given`/`when`, twigils, `multi`, `subset`,
junctions, and so on) may highlight imperfectly until the grammar matures.

## Installing as a dev extension

1. Make sure Rust is available (via [rustup](https://rustup.rs) is easiest, so
   that Zed can add the `wasm32-wasip2` target automatically).
2. In Zed, run the `zed: install dev extension` action and select this
   directory.

To avoid the existing Perl extension claiming Raku files, make sure the
`file_types` mapping in your Zed settings that routes `.raku`/`.rakumod`/etc. to
Perl is removed.

## Language server (optional)

[Raku Navigator](https://github.com/bscan/RakuNavigator) is not published to
npm, so this extension does not install it for you. To use it:

```sh
git clone https://github.com/bscan/RakuNavigator
cd RakuNavigator
npm install
npm run compile
```

Then point the extension at the compiled server in your Zed settings:

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

Alternatively, put a `raku-navigator` executable on your `PATH`.

## Grammar

The grammar is a fork of
[`acrion/tree-sitter-raku`](https://github.com/acrion/tree-sitter-raku) with the
generated parser committed so Zed can build it:
[`justaperlhacker/tree-sitter-raku`](https://github.com/justaperlhacker/tree-sitter-raku).
The pinned revision lives in `extension.toml`. To regenerate it, run
`scripts/build-grammar.sh`.

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
