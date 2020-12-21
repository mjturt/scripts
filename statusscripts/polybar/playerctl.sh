#!/bin/sh
# mjturt

PLAYER="spotify"
ARTIST_MAX_LENGTH=15
TITLE_MAX_LENGTH=15

PLAYER_STATUS="$(playerctl --player=$PLAYER status 2> /dev/null)"
GREEN="$(polybar -l error --dump=green colors)"
YELLOW="$(polybar -l error --dump=yellow colors)"
RED="$(polybar -l error --dump=red colors)"

if [ "$1" = "--info" ]; then
  INFO_STRING="$(playerctl --player=$PLAYER metadata artist 2> /dev/null | cut -c 1-$ARTIST_MAX_LENGTH) - $(playerctl --player=$PLAYER metadata title 2> /dev/null | cut -c 1-$TITLE_MAX_LENGTH)"
  if [ "$PLAYER_STATUS" = "Playing" ]; then
    PREFIX="%{F$GREEN}%{F-}"
  elif [ "$PLAYER_STATUS" = "Paused" ]; then
    PREFIX="%{F$YELLOW}%{F-}"
  else
    PREFIX="%{F$RED}%{F-}"
  fi
  echo "$PREFIX $INFO_STRING"
elif [ "$1" = "--no-info" ]; then
  if [ "$PLAYER_STATUS" = "Playing" ]; then
    echo "%{F$GREEN}%{F-}"
  elif [ "$PLAYER_STATUS" = "Paused" ]; then
    echo "%{F$YELLOW}%{F-}"
  else
    echo "%{F$RED}%{F-}"
  fi
elif [ "$1" = "--previous" ]; then
  playerctl --player="$PLAYER" previous 
elif [ "$1" = "--next" ]; then
  playerctl --player="$PLAYER" next 
elif [ "$1" = "--play" ]; then
  playerctl --player="$PLAYER" play-pause 
else
  echo "Command needed"
fi
