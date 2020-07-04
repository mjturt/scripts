#!/usr/bin/env bash
# mjturt

if [ "$1" == "--ryzen" ]; then
    TEMP=$(sensors | grep "Tctl" | awk '{print $2}' | tr -d "+°C")
else
    TEMP=$(sensors | grep "^temp" | awk '{print $2}' | tr -d "+°C")
fi

if (($(echo "$TEMP < 60" | bc -l))); then
    SYMBOL="%{F#11DF00}%{F-}"
elif (($(echo "$TEMP < 75" | bc -l))); then
    SYMBOL="%{F#f57800}%{F-}"
else
    SYMBOL="%{F#d300c4}%{F-}"
fi

echo -e "$SYMBOL $TEMP°C"
