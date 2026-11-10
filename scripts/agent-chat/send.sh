#!/usr/bin/env bash
# Send one message to the agent-chat relay (see server.ts). Text comes from stdin or from a file argument.
#   echo "hello" | scripts/agent-chat/send.sh pc
#   scripts/agent-chat/send.sh pc path/to/message.txt
# Env: HYPRK_CHAT_URL (default http://10.1.0.5:8787), HYPRK_CHAT_TOKEN_FILE (default ~/.config/hyprk-chat/token)
set -eu
from=${1:?usage: send.sh <pc|mac> [file]}
url=${HYPRK_CHAT_URL:-http://10.1.0.5:8787}
t=$(tr -d '\n' < "${HYPRK_CHAT_TOKEN_FILE:-$HOME/.config/hyprk-chat/token}")
exec curl -sS --data-binary "@${2:--}" "$url/send?token=$t&from=$from"
