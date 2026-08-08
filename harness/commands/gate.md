---
description: Check whether the active feature may be closed, and explain exactly what is missing
argument-hint: "[feature id or name, or blank for the active one]"
allowed-tools: Read, Glob, Grep, Bash
---

Check the gate for: $ARGUMENTS (default: the feature currently `in_progress`).

1. `./harness status`
2. `./harness gate <id>`

Then explain, in plain language, what each blocked item means and what has to
happen to clear it — which agent needs to run, or which command.

Do not attempt to clear the gate yourself by editing reports or re-running
verification with steps skipped. The gate exists to be told the truth.
