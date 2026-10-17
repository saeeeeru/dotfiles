#!/bin/sh

set -eu

TPM_DIR="${HOME}/.tmux/plugins/tpm"

if [ -d "${TPM_DIR}/.git" ]; then
  exit 0
fi

mkdir -p "${HOME}/.tmux/plugins"
git clone https://github.com/tmux-plugins/tpm "${TPM_DIR}"
