---
description: Run one feature end to end through the agent chain (implementer → reviewer → tester → gate)
argument-hint: "[feature id or name, or blank for the next pending one]"
allowed-tools: Read, Glob, Grep, Bash, Agent
---

Run one feature through the full harness chain. Feature: $ARGUMENTS

You are the `leader`. Follow `.claude/agents/leader.md`.

1. `./harness doctor` — stop and report if it fails.
2. If no feature was given, `./harness feature next`. Show it and confirm before starting.
3. `./harness feature start <id>`.
4. Write the plan into `progress/current.md`.
5. Launch, strictly in sequence, one at a time:
   - `implementer` → returns `progress/impl_<name>.md`
   - `reviewer` → returns `progress/review_<name>.md`
   - `tester-auto` → returns `progress/test_<name>.md`
   - `tester-manual` → appends the exploratory half to the same file
6. On any `VERDICT: FAIL`, send it back to the implementer with the specific
   findings, then re-run the reviewer and testers. Do not proceed past a FAIL.
7. `./harness feature done <id>` — the gate runs first and refuses when red.

Report to the human: what closed, the gate result, and the path to the latest
report folder. Do not paste code, diffs, or test output.
