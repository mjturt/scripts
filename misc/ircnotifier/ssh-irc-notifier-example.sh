#!/usr/bin/env bash

SSH_URL="user@host"
REMOTE_LOG_PATH="/path/to/logs/*.weechatlog"
PYTHON_SCRIPT_PATH="$HOME/scripts/parse-and-notify.py"
TAIL="tail"
[ "$(uname)" == "FreeBSD" ] && TAIL="gtail"

ssh "$SSH_URL" "$TAIL -q -n0 -f $REMOTE_LOG_PATH" | $PYTHON_SCRIPT_PATH
