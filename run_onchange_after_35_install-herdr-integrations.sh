#!/bin/sh

set -eu

PATH="${HOME}/.local/bin:${PATH}"

if ! command -v herdr >/dev/null 2>&1; then
  exit 0
fi

# Installs (or refreshes) an official Herdr agent integration when missing or outdated.
ensure_integration() {
  target="$1"
  config_dir="$2"

  if [ ! -d "${config_dir}" ]; then
    return 0
  fi

  line="$(herdr integration status 2>/dev/null | grep "^${target}:" || true)"
  case "${line}" in
    *": current "*)
      return 0
      ;;
  esac

  herdr integration install "${target}"
}

ensure_integration "claude" "${HOME}/.claude"
ensure_integration "codex" "${HOME}/.codex"
ensure_integration "cursor" "${HOME}/.cursor"
