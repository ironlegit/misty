#!/usr/bin/env bash
# Deterministic pre_tool_use gate for Misty.
#  1. Blocks dependency-install invocations anywhere in a shell command —
#     not just ones that literally start with the denied phrase, closing
#     the "python -m pip install" / "source venv && pip install" bypass.
#  2. Blocks any file write/edit while HEAD is on main, regardless of
#     what the agent's instructions say it *intends* to do next.
# Runs with preempt_yolo:true, so it fires before deny/allow/ask AND
# before --yolo — every run, every mode. A crash here fails CLOSED
# (blocks), matching cagent's default pre_tool_use posture.
set -euo pipefail

INPUT="$(cat)"
TOOL_NAME="$(jq -r '.tool_name // empty' <<<"$INPUT")"
CMD="$(jq -r '.tool_input.cmd // empty' <<<"$INPUT")"

WORKSPACE=/workspace
CURRENT_BRANCH="$(git -C "$WORKSPACE" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"

block() {
  jq -n --arg reason "$1" '{decision: "block", reason: $reason}'
  exit 2
}

# --- Check 1: dependency installation, anywhere in the command string ---
# Not anchored to the start, so chained/prefixed/aliased invocations are
# caught too. Not exhaustive by ecosystem — extend as needed — but the
# *shape* of the check (substring, not prefix) is what matters.
INSTALL_RE='(^|[^a-zA-Z0-9_])(pip[0-9]?[[:space:]]+install|-m[[:space:]]+pip[[:space:]]+install|npm[[:space:]]+(install|ci|i[[:space:]])|npx[[:space:]]|yarn[[:space:]]+add|pnpm[[:space:]]+add|poetry[[:space:]]+(add|install)|uv[[:space:]]+(add|sync|pip)|conda[[:space:]]+install|easy_install|gem[[:space:]]+install|cargo[[:space:]]+install)'
if [[ "$TOOL_NAME" == "shell" ]] && echo "$CMD" | grep -qiE "$INSTALL_RE"; then
  block "Dependency installation is forbidden by project policy (matched an install pattern in: $CMD). Declare the dependency in the manifest file and note the install step in the PR's 'How to verify' section instead."
fi

# --- Check 2: no writes/edits while HEAD is main (or unresolved) ---
MUTATING_TOOLS='^(edit_file|write_file|create_directory)$'
GIT_BOOTSTRAP_RE='^git[[:space:]]+(checkout|switch|pull|fetch|branch|status|log|diff|rev-parse|remote)\b'
READONLY_SHELL_RE='^(ls|cat|grep|find|head|tail|wc|pwd|echo)\b'

if [[ "$CURRENT_BRANCH" == "main" || "$CURRENT_BRANCH" == "HEAD" || "$CURRENT_BRANCH" == "unknown" ]]; then
  if [[ "$TOOL_NAME" =~ $MUTATING_TOOLS ]]; then
    block "Currently on '$CURRENT_BRANCH'. Run 'git checkout main && git pull && git checkout -b agent/<feature>' before writing or editing any file."
  fi
  if [[ "$TOOL_NAME" == "shell" ]] && ! echo "$CMD" | grep -qE "$GIT_BOOTSTRAP_RE|$READONLY_SHELL_RE"; then
    block "Currently on '$CURRENT_BRANCH'. Create and switch to a branch (git checkout -b agent/<feature>) before running: $CMD"
  fi
fi

echo '{}'
exit 0
