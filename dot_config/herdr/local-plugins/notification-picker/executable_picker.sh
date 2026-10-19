#!/bin/sh
# Pick an agent in the order it completed (newest first) and focus its tab.
# Only the latest completion per agent is known, so earlier completions in the same pane are not listed.
# Search is off until "/" is pressed; until then typed characters are discarded and j/k move.
# The list runs with the ASCII input source so j/k reach fzf while an IME is active; search and
# exit restore the input source that was selected when the popup opened.

herdr="${HERDR_BIN_PATH:-herdr}"
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
list_help='j/k move · enter focus · / search · q/esc close'
search_help='type to filter · enter focus · esc back to list'
list_keys='j,k,q,/,change'

tab_id=$(
  "$herdr" api snapshot | jq -r '
    .result.snapshot
    | ([.workspaces[] | {(.workspace_id): .label}] | add) as $ws
    | .agents
    | map(select(.completion_seq != null))
    | sort_by(-.completion_seq)[]
    | [.tab_id, (.completion_seq | tostring), .agent_status, ($ws[.workspace_id] // .workspace_id), (.terminal_title_stripped // "")]
    | @tsv' |
    fzf --delimiter '\t' --with-nth 2.. --no-sort --reverse \
      --disabled --prompt "$list_prompt" --footer "$list_help" \
      --bind 'j:down,k:up,q:abort,change:clear-query' \
      --bind "/:enable-search+unbind($list_keys)+change-prompt($search_prompt)+change-footer($search_help)+execute-silent($to_original)" \
      --bind "esc:transform:[ \"\$FZF_PROMPT\" = '$search_prompt' ] && echo 'disable-search+clear-query+rebind($list_keys)+change-prompt($list_prompt)+change-footer($list_help)+execute-silent($to_ascii)' || echo abort" |
    cut -f1
)

[ -n "$tab_id" ] && "$herdr" tab focus "$tab_id"
