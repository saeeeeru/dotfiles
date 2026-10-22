#!/bin/sh
# Pick an agent in the order it completed (newest first) and focus its tab.
# Only the latest completion per agent is known, so earlier completions in the same pane are not listed.
# The preview shows the last message of the highlighted agent's Claude Code session.
# Visible columns are space-padded into one field, since fzf expands tabs to tab stops and
# a long workspace label would push the columns after it out of line.
# Search is off until "/" is pressed; until then typed characters are discarded and j/k move.
# The list runs with the ASCII input source so j/k reach fzf while an IME is active; search and
# exit restore the input source that was selected when the popup opened.

herdr="${HERDR_BIN_PATH:-herdr}"
plugin_dir=$(cd "$(dirname "$0")" && pwd)
ascii_source='com.apple.keylayout.ABC'
if command -v macism >/dev/null 2>&1; then
  original_source=$(macism)
  to_ascii="macism $ascii_source"
  to_original="macism $original_source"
  trap '$to_original' EXIT
  $to_ascii
else
  to_ascii=true
  to_original=true
fi
list_prompt='/ to search > '
search_prompt='search > '
list_help='j/k move · ctrl-d/u scroll message · enter focus · / search · q/esc close'
search_help='type to filter · ctrl-d/u scroll message · enter focus · esc back to list'
list_keys='j,k,q,/,change'

tab_id=$(
  "$herdr" api snapshot | jq -r '
    .result.snapshot
    | ([.workspaces[] | {(.workspace_id): .label}] | add) as $ws
    | .agents
    | map(select(.completion_seq != null))
    | sort_by(-.completion_seq)
    | map({
        tab: .tab_id,
        session: (.agent_session.value // ""),
        cols: [(.completion_seq | tostring), .agent_status, ($ws[.workspace_id] // .workspace_id), (.terminal_title_stripped // "")]
      })
    | (map(.cols[:3] | map(length)) | transpose | map(max)) as $w
    | .[]
    | [.tab, .session,
       ([range(0; 3) as $i | .cols[$i] + (" " * ($w[$i] - (.cols[$i] | length)))] + [.cols[3]] | join("  "))]
    | @tsv' |
    fzf --delimiter '\t' --with-nth 3 --no-sort --reverse \
      --disabled --prompt "$list_prompt" --footer "$list_help" \
      --preview "/bin/sh '$plugin_dir/last-message.sh' {2}" --preview-window 'down,60%,wrap' \
      --bind 'j:down,k:up,q:abort,change:clear-query' \
      --bind 'ctrl-d:preview-half-page-down,ctrl-u:preview-half-page-up' \
      --bind "/:enable-search+unbind($list_keys)+change-prompt($search_prompt)+change-footer($search_help)+execute-silent($to_original)" \
      --bind "esc:transform:[ \"\$FZF_PROMPT\" = '$search_prompt' ] && echo 'disable-search+clear-query+rebind($list_keys)+change-prompt($list_prompt)+change-footer($list_help)+execute-silent($to_ascii)' || echo abort" |
    cut -f1
)

[ -n "$tab_id" ] && "$herdr" tab focus "$tab_id"
