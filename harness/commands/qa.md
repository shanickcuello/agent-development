---
description: Run the QA half only — automated suite plus an exploratory walkthrough with screenshots
argument-hint: "[feature id or name, or blank for the active one]"
allowed-tools: Read, Glob, Grep, Bash, Agent
---

Run QA on: $ARGUMENTS (default: the feature currently `in_progress`).

Use this when the code already exists and you want it tested — no implementer.

1. `./harness status` to identify the feature.
2. Launch `tester-auto`: full `./harness verify`, criteria-to-test mapping,
   mutation check, missing tests written. Returns `progress/test_<name>.md`.
3. Launch `tester-manual`: `./harness explore <feature> --run`, then it reads
   the screenshots and appends its findings to the same report.
4. Report: verdicts, bug count, screenshot count, and the report folder path.

Show the human the report folder path so they can open `report.md` and see the
screenshots inline. Do not paste logs or images into chat.
