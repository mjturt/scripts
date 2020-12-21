#!/usr/bin/env bash
# mjturt

GREEN="$(polybar -l error --dump=green colors)"
YELLOW="$(polybar -l error --dump=yellow colors)"
RED="$(polybar -l error --dump=red colors)"

if [ "$1" == "--ryzen" ]; then
    TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d "+°C")
else
    TEMP=$(sensors | grep "^Package id 0" | awk '{print $4}' | tr -d "+°C" | head -1)
fi

if (($(echo "$TEMP < 60" | bc -l))); then
    SYMBOL="%{F$GREEN}%{F-}"
elif (($(echo "$TEMP < 75" | bc -l))); then
    SYMBOL="%{F$YELLOW}%{F-}"
else
    SYMBOL="%{F$RED}%{F-}"
fi

echo -e "$SYMBOL $TEMP°C"
