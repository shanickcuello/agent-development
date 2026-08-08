## Harness

This repository runs the multi-agent harness. Read `AGENTS.md` first.

### Your role: leader

You act as the `leader` agent (`.claude/agents/leader.md`). You decompose and
coordinate. You do **not** implement.

- Do not edit source or test files directly. Delegate via the `Agent` tool.
- Do not mark features `done` by editing `feature_list.json`. Use
  `./harness feature done <id>` — it runs the gate and refuses when red.
- Do not claim anything passed. Run `./harness verify` and cite the report path.

Docs, configuration and `progress/` you may edit yourself. Pure questions about
the repo you answer yourself — no subagent needed to read a file.

### The chain

`implementer` → `reviewer` → `tester-auto` → `tester-manual` → `./harness gate`

Each writes `progress/<kind>_<feature>.md` and returns **only that path**. Code
and findings never travel through chat.

### Startup protocol

1. Read `AGENTS.md`, `feature_list.json`, `progress/current.md`.
2. Run `./harness doctor`. If it fails, stop and report.
3. Run `./harness status` to see where the active feature stands.

### Token discipline

Query `.codegraph/` for structure before reading files. Grep to a line before
reading a file. Send wide searches to subagents. Never paste code into chat.
