# Agent map

> Progressive disclosure: this file is a map, not a rulebook. Read what the
> task needs, when it needs it. Do not load everything up front.

## Where to look

| You need to know | Read |
|------------------|------|
| What to build next | `feature_list.json` |
| What is happening right now | `progress/current.md` |
| What "correct" means here | `CHECKPOINTS.md` |
| How to prove something works | run `./harness verify` |
| What was decided before | `progress/history.md`, `docs/` |
| Who does what | `.claude/agents/` |

## The flow

```
leader ──▶ implementer ──▶ reviewer ──▶ tester-auto ──▶ tester-manual ──▶ gate
   │                                                                       │
   └───────────────────── back to implementer if any verdict is FAIL ◀──────┘
```

Nobody skips a station. The gate is a script, not a promise:

```bash
./harness gate <feature>
```

It reads files on disk. An agent that says "tests pass" without a green
`verify.json` newer than the last source change does not get through.

## Hard rules

1. **One feature at a time.** `./harness feature start <id>` refuses a second one.
2. **The leader never edits `src/` or tests.** It decomposes and delegates.
3. **Nobody closes their own work.** The implementer cannot write the review.
4. **Reports live on disk, not in chat.** Subagents write
   `progress/<kind>_<feature>.md` and return the path, nothing more.
5. **Verification is executed, never asserted.** Only `./harness verify` counts.

## Token discipline

Context is the scarcest resource in this repo. In order of preference:

1. **Query the graph, do not read the tree.** If `.codegraph/` exists, ask
   CodeGraph for structure (callers, dependencies, symbol definitions) instead
   of opening files to find out where things live.
2. **Read the slice, not the file.** Grep to the line, then read around it.
3. **Delegate wide searches.** A subagent that reads forty files and returns
   three sentences costs the leader three sentences.
4. **Never paste code into chat.** Return `progress/impl_x.md`, not its contents.

Shell output is compressed by RTK automatically — run commands normally.

## Commands you will actually use

```bash
./harness status              # where everything stands
./harness feature next        # what to build
./harness feature start <id>  # claim it
./harness verify              # lint + typecheck + unit + e2e, dated report
./harness explore <id> --run  # exploratory browser walkthrough + screenshots
./harness gate <id>           # may this be closed?
./harness feature done <id>   # close it (runs the gate first, refuses if red)
```
