#!/bin/sh

set -eu

PATH="${HOME}/.local/bin:${PATH}"

if ! command -v herdr >/dev/null 2>&1; then
  exit 0
fi

INSTALLED="$(herdr plugin list --json)"

# Installs a plugin, or replaces it when the installed source or ref differs.
# An empty ref follows the plugin's default branch.
ensure_plugin() {
  plugin_id="$1"
  source="$2"
  ref="$3"

  current="$(printf '%s' "${INSTALLED}" | jq -r --arg id "${plugin_id}" \
    '.result.plugins[] | select(.plugin_id == $id) | "\(.source.owner)/\(.source.repo)@\(.source.requested_ref // "")"')"

  if [ "${current}" = "${source}@${ref}" ]; then
    return 0
  fi

  if [ -n "${current}" ]; then
    herdr plugin uninstall "${plugin_id}"
  fi

  if [ -n "${ref}" ]; then
    herdr plugin install "${source}" --ref "${ref}" --yes
  else
    herdr plugin install "${source}" --yes
  fi
}

# chmarax.herdr-nvim comes from a fork that also mines Claude Code sub-agent transcripts.
ensure_plugin "herdr-repo-picker" "mayaton/herdr-repo-picker" "v0.2.0"
ensure_plugin "kaar.fzf-url" "kaar/herdr-fzf-url" ""
ensure_plugin "chmarax.herdr-nvim" "saeeeeru/herdr-nvim" "v1.1.0-subagents.1"
ensure_plugin "persiyanov.reviewr" "persiyanov/herdr-reviewr" "v0.44.0"
