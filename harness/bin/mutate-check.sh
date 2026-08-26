#!/usr/bin/env bash
#
# Mutation-check helper (see CLAUDE.md "Mutation check at spec close").
#
#   .harness/bin/mutate-check.sh <file> <old> <new> -- <test command...>
#
# Temporarily replaces the first occurrence of OLD with NEW in FILE, runs the
# test command, then unconditionally reverts FILE via `git checkout` — exact
# revert even on a crash or Ctrl-C, no manual re-edit needed.
#
# Exit codes:
#   0 = mutation caught (tests failed as expected) — coverage proven
#   1 = script error (pattern not found, dirty tree, bad args)
#   2 = mutation SURVIVED (tests stayed green) — coverage gap, strengthen the test
#
# Example:
#   .harness/bin/mutate-check.sh src/foo.ts 'a + b' 'a - b' -- npx vitest run src/foo.test.ts

set -euo pipefail

[[ $# -ge 4 ]] || { echo "Usage: mutate-check.sh <file> <old> <new> -- <test command...>" >&2; exit 1; }

FILE="$1"; OLD="$2"; NEW="$3"; shift 3
[[ "${1:-}" == "--" ]] || { echo "✗ expected -- before the test command" >&2; exit 1; }
shift
TEST_CMD=("$@")
[[ ${#TEST_CMD[@]} -gt 0 ]] || { echo "✗ no test command given" >&2; exit 1; }

[[ -f "$FILE" ]] || { echo "✗ no such file: $FILE" >&2; exit 1; }
git diff --quiet -- "$FILE" || { echo "✗ $FILE has uncommitted changes — commit or stash first" >&2; exit 1; }

trap 'git checkout -- "$FILE"' EXIT

python3 - "$FILE" "$OLD" "$NEW" <<'PY'
import sys
path, old, new = sys.argv[1], sys.argv[2], sys.argv[3]
text = open(path, encoding="utf-8").read()
if old not in text:
    print(f"✗ pattern not found in {path}: {old!r}", file=sys.stderr)
    sys.exit(1)
open(path, "w", encoding="utf-8").write(text.replace(old, new, 1))
PY

printf '→ mutated %s: %q -> %q\n' "$FILE" "$OLD" "$NEW"

if "${TEST_CMD[@]}"; then
  printf '\n\033[31m✗ MUTATION SURVIVED\033[0m — tests stayed green. Coverage gap: strengthen the test, then re-run.\n'
  exit 2
else
  printf '\n\033[32m✓ mutation caught\033[0m — tests failed as expected.\n'
  exit 0
fi
