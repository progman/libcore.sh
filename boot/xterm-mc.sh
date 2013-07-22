#!/bin/sh

export LANG='ru_RU.UTF-8';
export LANGUAGE="${LANG}";
export LC_CTYPE="${LANG}";
export LC_NUMERIC="${LANG}";
export LC_TIME="${LANG}";
export LC_COLLATE="${LANG}";
export LC_MONETARY="${LANG}";
export LC_MESSAGES="${LANG}";
export LC_PAPER="${LANG}";
export LC_NAME="${LANG}";
export LC_ADDRESS="${LANG}";
export LC_TELEPHONE="${LANG}";
export LC_MEASUREMENT="${LANG}";
export LC_IDENTIFICATION="${LANG}";
export LC_ALL="${LANG}";

export DISABLE_SET_LOCALE="1";
export EDITOR='mcedit';

xterm -geometry 84x52+0+0 -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -e mc &> /dev/null < /dev/null &
#xterm -geometry 112x61+0+0 -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=12' -e mc &> /dev/null < /dev/null &
