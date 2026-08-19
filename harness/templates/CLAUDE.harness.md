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

### Token discipline

If the CodeGraph MCP tools are available, use them first for structure —
`codegraph_explore`/`codegraph_node`/callers/callees answer "where is X" and
"who calls X" without reading whole files. The index syncs itself via a
post-commit git hook, so it should be current; if it looks stale mid-session
(uncommitted changes it hasn't seen yet), run `codegraph sync` by hand. Fall
back to grep-to-a-line-then-read when CodeGraph isn't installed or doesn't
have the answer. Never paste code into chat needlessly.
