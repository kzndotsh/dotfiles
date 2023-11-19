#!/bin/sh
if [ "$TERM" = "linux" ]; then
  /bin/echo -e "
  \e]P015161e
  \e]P1f7768e
  \e]P29ece6a
  \e]P3e0af68
  \e]P47aa2f7
  \e]P5bb9af7
  \e]P67dcfff
  \e]P7a9b1d6
  \e]P8414868
  \e]P9f7768e
  \e]PA9ece6a
  \e]PBe0af68
  \e]PC7aa2f7
  \e]PDbb9af7
  \e]PE7dcfff
  \e]PFc0caf5
  "
  # get rid of artifacts
  clear
fi
