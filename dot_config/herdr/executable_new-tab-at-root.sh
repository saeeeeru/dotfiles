#!/bin/sh
# Herdr custom command: open a new tab at the main worktree of the focused pane's repository.
# Outside a git repository the focused pane's cwd is used as is.

cwd="${HERDR_ACTIVE_PANE_CWD:-$HOME}"
root=$(git -C "$cwd" worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p')

exec "${HERDR_BIN_PATH:-herdr}" tab create \
  --workspace "$HERDR_ACTIVE_WORKSPACE_ID" \
  --cwd "${root:-$cwd}" \
  --focus
