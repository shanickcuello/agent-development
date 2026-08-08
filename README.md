# agent-development

Multi-agent development harness. Drop it into any repository and get a
leader → implementer → reviewer → tester chain whose claims are checked by
scripts, not taken on trust.

```bash
bash /path/to/agent-development/harness.sh /path/to/your/project
```

One command. It detects the stack, scaffolds the state files, installs the
agents and hooks, wires the token-optimization layer, and runs a health check.

---

## Why a harness and not just prompts

`DEVELOPER.md` and `FRONTEND_WEB_DEV.md` in this repo are instructions — an
agent follows them when it feels like it. The harness is the part that does not
negotiate:

| Rule | Enforced by |
|------|-------------|
| One feature at a time | `harness feature start` refuses a second |
| Verification actually ran | `verify.json` on disk, with a timestamp |
| Verification is still valid | gate compares it against source mtimes |
| Reviewer approved | `VERDICT: PASS` grepped out of the review file |
| Tester approved | same, in the test file |
| Nothing was skipped | gate cross-checks skipped steps against the profile |

`harness gate` reads files. An agent that says "everything passes" without a
green run newer than its own last edit does not get through, and the hook that
runs the gate is executed by Claude Code, not by the model.

---

## Layout

```
agent-development/
├── DEVELOPER.md            # general engineering instructions
├── FRONTEND_WEB_DEV.md     # frontend-specific instructions
├── install-steps.md        # CodeGraph / RTK / Caveman install notes
├── harness.sh              # ← bootstrap: installs everything into a project
└── harness/
    ├── bin/harness         # the CLI (python3, zero dependencies)
    ├── bin/optimize.sh     # CodeGraph + RTK + Caveman layer
    ├── agents/             # leader, implementer, reviewer, tester-auto, tester-manual
    ├── commands/           # /feature /qa /gate /harness-status
    ├── hooks/settings.json # PostToolUse + Stop
    ├── profiles/           # node-web, python-web, flutter, go, generic
    └── templates/          # AGENTS.md, CHECKPOINTS.md, report skeletons, specs
```

After installing, the target project gets:

```
your-project/
├── harness                 # ./harness — entry point
├── .harness/               # the copied harness + profile.env + run state
├── AGENTS.md               # map for agents (progressive disclosure)
├── CHECKPOINTS.md          # what "correct final state" means here
├── feature_list.json       # scope, one feature at a time
├── progress/               # impl_*, review_*, test_*, current.md, history.md
├── test-reports/           # dated run folders (gitignored)
└── .claude/agents|commands|settings.json
```

---

## Stack-agnostic by design

The harness knows nothing about your stack. Everything it runs comes from
`.harness/profile.env`:

```bash
HARNESS_LINT=npm run lint
HARNESS_TYPECHECK=npm run typecheck
HARNESS_UNIT=npm run test
HARNESS_E2E=npx playwright test --config .harness/playwright.harness.ts
HARNESS_E2E_KIND=playwright
HARNESS_SOURCE_GLOBS=src/**/*,e2e/**/*
```

`harness init` guesses these from what it finds — package.json scripts, the
lockfile's package manager, the `baseURL` in your Playwright config. Then it is
a plain text file: change a line and you have changed the stack.

Shipped profiles: `node-web` (Next.js / Vite / React / anything with a
package.json), `python-web` (FastAPI / FastHTML / Django / Flask),
`flutter`, `go`, `generic`. Adding one is a new `.env` file in `profiles/`.

Empty value = step skipped. A repo with no E2E still works.

---

## The agent chain

```
leader ──▶ implementer ──▶ reviewer ──▶ tester-auto ──▶ tester-manual ──▶ gate
   │                                                                       │
   └───────────────────── back to implementer if any verdict is FAIL ◀──────┘
```

- **leader** — decomposes and delegates. Cannot edit `src/`, cannot close features.
- **implementer** — one feature, test-first, writes `progress/impl_<f>.md`.
- **reviewer** — five axes (correctness, architecture, readability, security,
  tests) including mutation thinking. Cannot edit code. Writes a verdict.
- **tester-auto** — runs the suite, maps every acceptance criterion to a test
  that would catch its violation, writes the missing ones.
- **tester-manual** — exploratory QA. Drives the real browser, screenshots every
  step, then *looks at the screenshots*.

Subagents write to `progress/` and return only the path. Code never travels
through chat — it stays on disk, auditable and versioned, and it costs the
leader's context once, when the leader chooses.

---

## Testing, both kinds

**Automated** is the deterministic suite. `./harness verify` runs lint →
typecheck → unit → e2e and writes a dated folder:

```
test-reports/test_<feature>_2026-08-07_16-02-27/
├── report.md              # steps table + every screenshot embedded
├── verify.json            # machine-readable, what the gate reads
├── screenshots/           # 001-landing.png, 002-after-submit.png, ...
├── playwright-report/     # HTML report with traces
├── artifacts/
└── logs/{lint,typecheck,unit,e2e}.log
```

**Exploratory** is the "manual" test, automated:

```bash
./harness explore checkout-flow          # scaffolds e2e/exploratory/checkout-flow.spec.ts
./harness explore checkout-flow --run    # runs it, captures screenshots
```

The scaffold ships a `shot()` helper wired to the run's report folder. The
tester writes the steps a human would perform and screenshots each one. Then it
reads the images — because "the test passed" and "the screen looks right" are
different claims, and only one of them is asserted.

Screenshots and traces are forced on via `.harness/playwright.harness.ts`, which
extends your existing Playwright config without modifying it.

---

## Token optimization

Run by the bootstrap, or on demand:

```bash
./harness optimize              # detect and report
./harness optimize --install    # also run the third-party installers
```

- **RTK** compresses shell output before it reaches the agent (60–90% on dev
  operations). Checks for the `rtk-ai/rtk` vs `Rust Type Kit` name collision.
- **CodeGraph** builds a semantic graph of the repo so agents query structure
  instead of reading files to discover it. Indexes the project and turns
  telemetry off.
- **Caveman** compresses agent output, and `/caveman-compress CLAUDE.md` pays
  off on every session afterwards.

It also flags an oversized `CLAUDE.md` — that file is loaded into every single
session, so its word count is a recurring tax.

The agents are instructed to match: query the graph before reading the tree,
grep to a line before reading a file, delegate wide searches, never paste code
into chat.

Detection only by default. `--install` is opt-in because those installers pipe
`curl` into a shell.

---

## Commands

```bash
./harness status              # one screen: active feature, reports, freshness
./harness doctor              # health check, non-zero if unusable
./harness feature list|next   # scope
./harness feature start <id>  # claim one — refuses if another is open
./harness verify [--fast]     # full run into a dated report folder
./harness explore <f> --run   # exploratory walkthrough with screenshots
./harness gate <id>           # may this be closed, and if not, why
./harness feature done <id>   # close it — runs the gate first, refuses if red
./harness report <kind> <f>   # scaffold impl/review/test/explore report
./harness optimize            # CodeGraph + RTK + Caveman
```

In Claude Code: `/feature`, `/qa`, `/gate`, `/harness-status`.

---

## Re-running the bootstrap

It is idempotent. `harness.sh` replaces `.harness/{bin,agents,commands,hooks,profiles,templates}`
wholesale and leaves your state alone — `profile.env`, `feature_list.json`,
`progress/`, `CHECKPOINTS.md` are never overwritten. Hooks merge into an
existing `.claude/settings.json` instead of replacing it; the `CLAUDE.md` block
sits between `<!-- BEGIN HARNESS -->` markers and is refreshed in place.

So updating a project to a newer harness is the same command that installed it.
