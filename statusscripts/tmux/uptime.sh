#!/usr/bin/env bash
echo "$(uptime | cut -f 4-5 -d ' ' | sed 's/days,/d/' | sed 's/hours,/h/' | tr -d , )"
