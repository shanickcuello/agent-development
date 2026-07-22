# Codegraph

https://github.com/colbymchenry/codegraph

CodeGraph builds a semantic knowledge graph of an entire repository, including functions, classes, and dependencies. Instead of having AI agents manually read and parse thousands of lines of code, it allows them to immediately query the exact structure of the project.

#### macOS / Linux
`curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh`

#### Windows (PowerShell)
`irm https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.ps1 | iex`

`codegraph install`

`cd your-project`
`codegraph init`

#### Uninstall 
`codegraph uninstall`

`codegraph telemetry off`

---

# RTK library

https://github.com/rtk-ai/rtk

RTK (Rust Token Killer) is a free, open-source CLI proxy that compresses command-line outputs before they reach your AI coding agent (like Claude Code, Cursor, or Copilot), reducing token consumption by 60–90%.

#### Mac
`brew install rtk`

Linux macos
`curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh`
Add to path
`echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc  # or ~/.zshrc`

#### After installation 
```
# 1. Install for your AI tool
rtk init -g                     # Claude Code / Copilot (default)
rtk init -g --gemini            # Gemini CLI
rtk init -g --codex             # Codex (OpenAI)
rtk init -g --agent cursor      # Cursor
rtk init -g --agent windsurf    # Windsurf
rtk init --agent cline          # Cline / Roo Code
rtk init --agent kilocode       # Kilo Code
rtk init --agent antigravity    # Google Antigravity
rtk init -g --agent pi          # Pi
rtk init --agent hermes         # Hermes

# 2. Restart your AI tool, then test
git status  # Automatically rewritten to rtk git status
```
---

# Caveman

https://github.com/juliusbrussee/caveman

Caveman is a skill/plugin for Claude Code, Codex, Gemini, Cursor, Windsurf, Cline, Copilot, and 30+ other agents. Install once. Agent drops the filler and answers in tight caveman-speak, keeping code, commands, and errors byte-for-byte exact. You save output tokens on every reply, forever.

#### macOS · Linux · WSL · Git Bash
`curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash`

#### Windows · PowerShell 5.1+
`irm https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.ps1 | iex`

#### Usage
Turn it on: type /caveman or say "talk like caveman". Turn it off: say "normal mode". On Claude Code, Codex, and Gemini it's already on from message one. No command needed.

```
/caveman [lite|full|ultra|wenyan]	Compress every reply. Level sticks for the session.
/caveman-commit	Conventional Commit messages, ≤50-char subject. Why over what.
/caveman-review	One-line PR comments: L42: 🔴 bug: user null. Add guard.
/caveman-stats	Real session token usage, lifetime savings, USD. Tweetable line with --share.
/caveman-compress <file>	Rewrite a memory file (like CLAUDE.md) into caveman-speak. Cuts ~46% input tokens every session after. Code, URLs, paths byte-preserved.
caveman-shrink	MCP middleware. Wraps any MCP server, compresses its tool descriptions. npm.
cavecrew-*	Caveman subagents (investigator, builder, reviewer). ~60% fewer tokens than vanilla, so main context lasts longer.
```
### Uninstall
npx -y github:JuliusBrussee/caveman -- --uninstall

---

## Final recommendations

Active Session Management:
- Auditing: We always recommend using the /context command to review which files or data are currently impacting your token usage.

- Cleanup: We always recommend using /clear after finishing tasks to effectively reset your context history.

- Model Selection: We always recommend that you don't necessarily need to use the most powerful model; for web navigation or simple tasks, Haiku is a great choice, while Sonnet is suggested for repetitive, automatable tasks.
