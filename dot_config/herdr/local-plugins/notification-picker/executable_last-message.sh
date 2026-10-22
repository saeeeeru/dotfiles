#!/bin/sh
# Print the last assistant text of a Claude Code session.
# Only the transcript tail is read; a final turn longer than that shows an earlier message.

session_id="$1"
transcript=$(ls "$HOME"/.claude/projects/*/"$session_id".jsonl 2>/dev/null | head -n 1)
if [ -z "$session_id" ] || [ -z "$transcript" ]; then
  echo '(no transcript)'
  exit 0
fi

tail -n 300 "$transcript" | jq -rs '
  [.[]
   | select(.type == "assistant")
   | [.message.content[]? | select(.type == "text") | .text]
   | join("\n")
   | select(. != "")]
  | last // "(no message)"'
