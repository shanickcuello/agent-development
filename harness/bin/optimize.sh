#!/usr/bin/env bash
#
# Token optimization layer — CodeGraph + RTK + Caveman.
#
# The harness controls *what* agents do. This controls *how much context it
# costs*. Detects what is installed, wires what it can, and prints the exact
# command for whatever is missing.
#
# By default this only inspects and reports. Pass --install to let it actually
# run third-party installers (they pipe curl into a shell — your call).
#
# Usage:  optimize.sh <project-root> [--install]

set -uo pipefail

PROJECT_ROOT="${1:?usage: optimize.sh <project-root> [--install]}"
DO_INSTALL="${2:-}"

BOLD=$'\033[1m'; DIM=$'\033[2m'; RED=$'\033[31m'; GREEN=$'\033[32m'
YELLOW=$'\033[33m'; BLUE=$'\033[34m'; RESET=$'\033[0m'
[[ -t 1 ]] || { BOLD=""; DIM=""; RED=""; GREEN=""; YELLOW=""; BLUE=""; RESET=""; }

ok()   { printf '%s✓%s %s\n' "$GREEN" "$RESET" "$1"; }
warn() { printf '%s!%s %s\n' "$YELLOW" "$RESET" "$1"; }
info() { printf '%s·%s %s\n' "$BLUE" "$RESET" "$1"; }
hint() { printf '    %s%s%s\n' "$DIM" "$1" "$RESET"; }

want_install() { [[ "$DO_INSTALL" == "--install" ]]; }

printf '\n%sToken optimization%s\n' "$BOLD" "$RESET"

# ---------------------------------------------------------------------------
# RTK — compresses shell output before it reaches the agent (60-90% on dev ops)
# ---------------------------------------------------------------------------
if command -v rtk >/dev/null 2>&1; then
  if rtk gain >/dev/null 2>&1; then
    ok "RTK installed and responding ($(rtk --version 2>/dev/null | head -1))"
    if [[ ! -f "$HOME/.claude/settings.json" ]] || ! grep -q "rtk" "$HOME/.claude/settings.json" 2>/dev/null; then
      warn "RTK is installed but the Claude Code hook may not be wired"
      hint "rtk init -g"
    fi
  else
    warn "A binary named 'rtk' exists but 'rtk gain' failed — likely the wrong rtk"
    hint "You may have reachingforthejack/rtk (Rust Type Kit) instead of rtk-ai/rtk"
    hint "which rtk   # check which one is on PATH"
  fi
elif want_install; then
  info "Installing RTK…"
  if command -v brew >/dev/null 2>&1; then
    brew install rtk && ok "RTK installed"
  else
    curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/refs/heads/master/install.sh | sh \
      && ok "RTK installed — add ~/.local/bin to PATH if it is not already"
  fi
  command -v rtk >/dev/null 2>&1 && rtk init -g
else
  warn "RTK not installed — shell output reaches the agent uncompressed"
  hint "brew install rtk   # then: rtk init -g"
fi

# ---------------------------------------------------------------------------
# CodeGraph — semantic graph of the repo, so agents query structure
#             instead of reading thousands of lines to find it
# ---------------------------------------------------------------------------
if command -v codegraph >/dev/null 2>&1; then
  ok "CodeGraph installed"
  if [[ -d "$PROJECT_ROOT/.codegraph" ]]; then
    ok "CodeGraph index present in this project (.codegraph/)"
    hint "Refresh it after large refactors:  codegraph init"
  else
    info "Indexing this project…"
    ( cd "$PROJECT_ROOT" && codegraph init ) \
      && ok "CodeGraph index created" \
      || warn "codegraph init failed — run it by hand in $PROJECT_ROOT"
  fi
  # Register the MCP server too — the binary being installed doesn't imply the
  # agent has it wired up. Idempotent: re-running just rewrites the same config.
  codegraph install -y >/dev/null 2>&1 && ok "CodeGraph MCP server registered" \
    || warn "codegraph install failed — run it by hand: codegraph install"
  codegraph telemetry off >/dev/null 2>&1 && info "CodeGraph telemetry off"
elif want_install; then
  info "Installing CodeGraph…"
  curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh
  if command -v codegraph >/dev/null 2>&1; then
    codegraph install -y >/dev/null 2>&1
    codegraph telemetry off >/dev/null 2>&1
    ( cd "$PROJECT_ROOT" && codegraph init ) && ok "CodeGraph installed and indexed"
  fi
else
  warn "CodeGraph not installed — agents will read files to discover structure"
  hint "curl -fsSL https://raw.githubusercontent.com/colbymchenry/codegraph/main/install.sh | sh"
  hint "codegraph install && cd $PROJECT_ROOT && codegraph init"
fi

# ---------------------------------------------------------------------------
# Caveman — compresses agent *output*; also compresses memory files once
# ---------------------------------------------------------------------------
CAVEMAN_FOUND=""
for candidate in "$HOME/.claude/skills/caveman" "$HOME/.claude/plugins/caveman" \
                 "$PROJECT_ROOT/.claude/skills/caveman"; do
  [[ -e "$candidate" ]] && CAVEMAN_FOUND="$candidate" && break
done

if [[ -n "$CAVEMAN_FOUND" ]]; then
  ok "Caveman installed ($CAVEMAN_FOUND)"
  hint "/caveman lite            # compress replies for this session"
  hint "/caveman-compress CLAUDE.md   # one-off: ~46% off every future session"
elif want_install; then
  info "Installing Caveman…"
  curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash \
    && ok "Caveman installed"
else
  warn "Caveman not installed — agent replies stay uncompressed"
  hint "curl -fsSL https://raw.githubusercontent.com/JuliusBrussee/caveman/main/install.sh | bash"
fi

# ---------------------------------------------------------------------------
# Project-level context hygiene
# ---------------------------------------------------------------------------
printf '\n%sContext hygiene%s\n' "$BOLD" "$RESET"

CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"
if [[ -f "$CLAUDE_MD" ]]; then
  WORDS=$(wc -w < "$CLAUDE_MD" | tr -d ' ')
  if (( WORDS > 1200 )); then
    warn "CLAUDE.md is ~$WORDS words — it is loaded on every single session"
    hint "/caveman-compress CLAUDE.md   # or move detail into docs/ and link it"
  else
    ok "CLAUDE.md is ~$WORDS words (loaded every session — keep it lean)"
  fi
fi

if [[ -d "$PROJECT_ROOT/node_modules" ]] && ! grep -q "node_modules" "$PROJECT_ROOT/.gitignore" 2>/dev/null; then
  warn "node_modules is not gitignored — agents may wander into it"
fi

printf '\n'
info "Per-session habits that cost nothing:"
hint "/context   audit what is eating the window"
hint "/clear     reset between unrelated tasks"
hint "Haiku for navigation and repetitive work, Sonnet for automatable loops"

exit 0
