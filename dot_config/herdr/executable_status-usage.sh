#!/bin/sh
# Herdr tab bar entry: Claude Code rate limits cached by ~/.claude/scripts/statusline.js.
# The cache refreshes only while some Claude Code session renders its status line,
# so the age is appended once it is older than STALE_MINUTES.

set -eu

CACHE="${HOME}/.claude/usage-cache.json"
STALE_MINUTES=15

[ -r "${CACHE}" ] || exit 0

jq -r --argjson stale "${STALE_MINUTES}" '
  def local_reset:
    sub("\\.[0-9]+"; "") | sub("(\\+00:00|Z)$"; "Z") | fromdateiso8601 | localtime;
  def reset_label:
    if . == null then ""
    else (local_reset) as $t
      | if ($t | strftime("%Y-%m-%d")) == (now | localtime | strftime("%Y-%m-%d"))
        then " ~" + ($t | strftime("%H:%M"))
        else " ~" + ($t | strftime("%-m/%-d %H:%M"))
        end
    end;
  def limit_name:
    if .kind == "session" then "cur"
    elif .kind == "weekly_all" then "wk"
    elif .kind == "weekly_scoped" then ((.scope.model.display_name // "scp") | ascii_downcase | .[0:3])
    else empty
    end;
  ((now - (.fetchedAt / 1000)) / 60 | floor) as $age
  | [.limits[]? | limit_name as $l | "\($l):\(.percent | floor)%\(.resets_at | reset_label)"]
  | join(" · ")
  | if . == "" then empty
    elif $age >= $stale then . + " (\($age)m ago)"
    else .
    end
' "${CACHE}"
