#!/bin/sh

set -eu

CODEX_DIR="${HOME}/.codex"
CONFIG_FILE="${CODEX_DIR}/config.toml"
TMP_FILE="${CONFIG_FILE}.tmp"

mkdir -p "${CODEX_DIR}"

if [ ! -f "${CONFIG_FILE}" ]; then
  cat >"${CONFIG_FILE}" <<'EOF'
[features]
codex_hooks = true
EOF
  exit 0
fi

awk '
BEGIN {
  in_features = 0
  saw_features = 0
  wrote_codex_hooks = 0
}
/^[[:space:]]*\[features\][[:space:]]*$/ {
  print
  in_features = 1
  saw_features = 1
  next
}
in_features && /^[[:space:]]*\[/ {
  if (!wrote_codex_hooks) {
    print "codex_hooks = true"
    wrote_codex_hooks = 1
  }
  in_features = 0
}
in_features && /^[[:space:]]*codex_hooks[[:space:]]*=/ {
  if (!wrote_codex_hooks) {
    print "codex_hooks = true"
    wrote_codex_hooks = 1
  }
  next
}
{
  print
}
END {
  if (in_features && !wrote_codex_hooks) {
    print "codex_hooks = true"
  }
  if (!saw_features) {
    print ""
    print "[features]"
    print "codex_hooks = true"
  }
}
' "${CONFIG_FILE}" >"${TMP_FILE}"

mv "${TMP_FILE}" "${CONFIG_FILE}"
