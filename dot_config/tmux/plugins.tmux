# TPM-managed plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'hiroppy/tmux-agent-sidebar'

# TPM must stay at the bottom of the plugin list.
if-shell '[ -x "$HOME/.tmux/plugins/tpm/tpm" ]' 'run-shell "$HOME/.tmux/plugins/tpm/tpm"'
