# agent-development

Spec-driven, TDD development harness. Drop it into any repository and get a
deterministic `verify` (lint + typecheck + unit + e2e) plus lightweight
conventions (spec docs, checkpoints) whose claims are checked by scripts, not
taken on trust.

**Default mode is inline, single-agent** (see `harness/templates/CLAUDE.harness.md`):
you write code and tests yourself, test-first, and gate on `./harness verify`.
The multi-agent chain (leader → implementer → reviewer → tester, `feature`,
`gate`) is kept below as an **optional** heavier workflow — opt in only when a
task genuinely needs it. It costs far more (cold-start subagents re-reading
context and re-running the slow suite) and is unnecessary for solo work.

---

## Install — once per project

**1. Get this repo** (once per machine)

```bash
git clone git@github.com:shanickcuello/agent-development.git ~/agent-development
```

**2. Run the bootstrap inside your project**

```bash
cd /path/to/your/project
bash ~/agent-development/harness.sh .
```

Detects the stack, scaffolds everything, wires the hooks, checks CodeGraph/RTK/Caveman.
Add `--install-tools` if you also want it to install the missing ones.

**3. Check what it guessed**

```bash
cat .harness/profile.env      # lint / typecheck / unit / e2e commands
```

Wrong command or port? Edit the line. That file is the whole stack config.

**4. Define your scope**

Replace the sample entry in `feature_list.json` with real features. Each needs a
`name` (reports are keyed by it), a `title`, and acceptance criteria specific
enough that a reviewer can tick them off without asking you anything.

**5. Restart Claude Code**

So it picks up the new agents, commands and hooks. Then confirm:

```bash
./harness doctor
```

Green means you are done. Re-run step 2 anytime to upgrade a project to a newer
harness — it never overwrites your state.

---

## Usage — every day

**1. See where you stand**

```bash
./harness status
```

Active feature, which reports exist, whether the last verification is green,
red, or stale.

**2. Run a feature**

In Claude Code:

```
/feature
```

That is the whole loop: picks the next pending feature, claims it, then runs
implementer → reviewer → tester-auto → tester-manual, sending work back on any
`FAIL`. Pass an id to choose: `/feature 3`.

**3. Watch it happen**

Open `progress/` in your editor. Each report appears as its subagent finishes —
`impl_*.md`, `review_*.md`, `test_*.md`. Nothing travels through chat, so this
is where you audit who decided what.

**4. Look at the screenshots**

```bash
open test-reports/<latest>/report.md
```

Every exploratory step, embedded in order. This is the part worth thirty
seconds of your attention — it catches what assertions never do.

**5. Close it**

```bash
./harness feature done <id>
```

Runs the gate first and refuses if anything is missing, red, or stale. When it
refuses, `./harness gate <id>` tells you exactly what to fix.

### The rest of the time

```bash
./harness verify --fast          # lint + typecheck + unit, no e2e
./harness explore <name> --run    # exploratory walkthrough on demand
/qa                               # test code that already exists, no implementer
/gate                             # what is blocking the active feature
```

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
