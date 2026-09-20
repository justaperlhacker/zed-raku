#!/usr/bin/env bash
#
# Regenerate the tree-sitter parser in the grammar fork and pin the resulting
# revision in extension.toml.
#
# The grammar repo does not commit `src/parser.c`, but Zed needs it to build
# the grammar, so we generate it and commit it to our fork.
#
# Usage: scripts/build-grammar.sh
# Env:   GRAMMAR_REPO  override the grammar remote (default: the fork)

set -euo pipefail

GRAMMAR_REPO="${GRAMMAR_REPO:-git@github-justaperlhacker:justaperlhacker/tree-sitter-raku.git}"
EXT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKDIR="$(mktemp -d)"
trap 'rm -rf "$WORKDIR"' EXIT

echo ">> Cloning $GRAMMAR_REPO"
git clone --quiet "$GRAMMAR_REPO" "$WORKDIR/grammar"

cd "$WORKDIR/grammar"
echo ">> Running tree-sitter generate"
tree-sitter generate

git add -f \
  src/parser.c \
  src/node-types.json \
  src/tree_sitter/parser.h \
  src/tree_sitter/array.h
git add src/grammar.json

if git diff --cached --quiet; then
  echo ">> Grammar unchanged; nothing to push"
else
  git commit --quiet -m "Regenerate parser"
  git push --quiet origin HEAD:main
fi

REV="$(git rev-parse HEAD)"
echo ">> Grammar revision: $REV"

python3 - "$EXT_DIR/extension.toml" "$REV" <<'PY'
import re
import sys

path, rev = sys.argv[1], sys.argv[2]
text = open(path).read()

section = re.compile(r"(\[grammars\.raku\]\n(?:.*\n)*?rev = \")([0-9a-f]+)(\")")
new_text, count = section.subn(lambda m: m.group(1) + rev + m.group(3), text)
if count != 1:
    sys.exit(f"expected exactly one [grammars.raku] rev, found {count}")

open(path, "w").write(new_text)
print(f">> Updated {path}")
PY
