# AGENTS.md

Guidance for AI agents working in this repository.

## What this is

A [Zed](https://zed.dev) extension providing [Raku](https://raku.org) language
support: a tree-sitter grammar, queries, and an optional RakuNavigator LSP.
**Experimental** — see `README.md`.

## Key facts

- The grammar is **not** in this repo. `extension.toml` pins a rev of the fork
  [`justaperlhacker/tree-sitter-raku`](https://github.com/justaperlhacker/tree-sitter-raku)
  (local checkout: `~/Projects/tree-sitter-raku`).
- Zed compiles the grammar's generated `src/parser.c`; it does **not** run
  `tree-sitter generate` and does not read `grammar.js`. Upstream gitignores
  `src/*`, so the fork force-commits the generated files.
- `grammar.js` is the grammar source; `src/scanner.c` is a hand-written external
  scanner; `src/parser.c` / `grammar.json` / `node-types.json` are generated.

## Commands

Extension (this repo):

```sh
cargo build --target wasm32-wasip2 --release
```

Query validation — run from the **grammar** dir so the local parser is used:

```sh
cd ~/Projects/tree-sitter-raku
for q in highlights brackets indents outline textobjects injections overrides; do
  tree-sitter query ~/Projects/zed-raku/languages/raku/$q.scm \
    ~/Projects/zed-raku/test/highlight.raku >/dev/null && echo "$q OK" || echo "$q FAIL"
done
```

Grammar (`~/Projects/tree-sitter-raku`):

```sh
timeout 300 tree-sitter generate     # SLOW (~1-2 min)
timeout 280 tree-sitter test         # baseline: 199 parses, 27 pre-existing failures
tree-sitter parse <file>             # test/highlight.raku must report 0 errors
```

Smoke-file validation:

```sh
raku -c ~/Projects/zed-raku/test/highlight.raku   # -> Syntax OK
```

## Workflow for grammar changes

1. Edit `grammar.js` (and `src/scanner.c` if needed) in the grammar repo.
2. `tree-sitter generate`; add a `conflicts` entry only when it asks; re-run and
   remove any "unnecessary conflicts" it reports.
3. `tree-sitter test` — confirm the failure set is unchanged.
4. Probe new syntax with `tree-sitter parse` on small files.
5. Commit source + force-add generated files, then push:
   ```sh
   git add grammar.js src/scanner.c
   git add -f src/parser.c src/node-types.json src/tree_sitter/parser.h \
              src/tree_sitter/array.h src/grammar.json
   git commit -m "..."; git push origin HEAD:main
   ```
6. In this repo: bump `[grammars.raku].rev` in `extension.toml`, update
   `languages/raku/highlights.scm` and `test/highlight.raku`, then commit + push.
7. Rebuild the dev extension in Zed (Extensions → **Raku** → **Rebuild**).

`scripts/build-grammar.sh` automates steps 2 + 5 + 6 (generate, push, rev bump).

## Conventions

- Work **one feature/gap group per commit**.
- Do not commit or push unless asked (except as part of an approved group
  workflow). Do not commit to the user's dotfiles repo unless asked.
- Keep the grammar test suite failure set unchanged.
- Do not add code comments unless asked.
- `parser.c` is ~55 MB (GitHub warns >50 MB, hard limit 100 MB). Avoid changes
  that inflate the parse table; inlining internal rules makes it **larger**.

## Gotchas

- `externals: [...]` in `grammar.js` must stay in the same order as the token
  enum in `src/scanner.c`.
- Do not delete `/home/johnm/Projects/zed-raku/grammars/` — it is Zed's
  dev-extension build output (`raku.wasm`, `pod.wasm`); deleting it breaks
  language loading until the next rebuild.
- Run `tree-sitter query` from the grammar dir; running it from this repo on an
  unknown file type can make the CLI auto-clone grammars into `grammars/`.
- Zed's installed dev extension is a symlink to this repo; grammar/query changes
  need a **Rebuild**.

## More detail

- `.plans/agent-notes.plan` — environment, paths, full gotcha list.
- `.plans/grammar-status.plan` — fixes done, gaps remaining, exact revs.
- `.plans/zed-raku-extension.plan` — original milestones.
