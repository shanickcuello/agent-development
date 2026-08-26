## Workflow — spec-driven TDD, inline

Work **inline**: you edit the source and tests yourself. Do **not** run a
multi-agent chain (separate implementer/reviewer/tester subagents) or a
`feature`/`gate` pipeline — it is expensive (cold start + re-reading + slow e2e
per agent) and unnecessary for a solo developer. Spawn a subagent only when the
human explicitly asks, or for a genuinely large parallel search.

### Organize work as spec docs

Numbered spec docs live in `docs/specs/spec-NNN-<slug>.md`: a short **Context**,
a **phased checklist** (`[ ]` / `[x]`), and exact acceptance / copy where it
matters. The spec is the backlog and the definition of done — not
`feature_list.json`.

### TDD is the rule

For each item, in this order:

1. **Unit test first** — write the failing test, watch it go red.
2. **Code** — implement until the unit test is green.
3. **E2E** — add/adjust the Playwright flow for anything user-facing.
4. **Verify** — run `./harness verify` (lint + typecheck + unit + e2e) and make
   it green. E2E is slow, so run the full suite **once per item/phase at the
   end**; use the unit runner for the fast red-green loop.
5. **Commit** — one coherent commit per item/phase.

Never claim something passed without running it. `./harness verify` (or the raw
`eslint` / typecheck / unit / e2e commands) is the guard.

### Mutation check at spec close

Before the spec's closing commit, pick the 1-2 most important behaviours added
across the spec (a condition, a comparison, a boolean flag) and mutate them.
Use the helper — it mutates, runs the tests, and reverts automatically (exact
revert via `git checkout`, one shell call instead of an edit/run/edit-back
loop):

```bash
.harness/bin/mutate-check.sh <file> '<old snippet>' '<new snippet>' -- <test command...>
```

Exit 0 = caught (good). Exit 2 = **survived** — the coverage is theatre:
strengthen the test so it would catch the mutation, then re-run the helper to
confirm exit 0 before committing.

### Token discipline

If the CodeGraph MCP tools are available, use them first for structure —
`codegraph_explore`/`codegraph_node`/callers/callees answer "where is X" and
"who calls X" without reading whole files. The index syncs itself via a
post-commit git hook, so it should be current; if it looks stale mid-session
(uncommitted changes it hasn't seen yet), run `codegraph sync` by hand. Fall
back to grep-to-a-line-then-read when CodeGraph isn't installed or doesn't
have the answer. Never paste code into chat needlessly.
