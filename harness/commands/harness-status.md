---
description: One-screen summary of the harness — active feature, reports present, verification freshness
allowed-tools: Read, Glob, Grep, Bash
---

Run `./harness status` and `./harness doctor --quick`, then summarise for the
human in a few lines:

- which feature is active and which reports already exist
- whether the last verification is green, red, or stale
- what the next concrete step is (which agent to launch, or which command)

If the verification is stale — source changed after the last green run — say so
explicitly. That is the most common reason a feature cannot close.

Keep it short. No code, no logs.
