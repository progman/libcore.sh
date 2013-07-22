#!/bin/sh

export LANG='ru_RU.CP1251';
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

#xterm -geometry 84x56+0+0 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e /bin/bash &
xterm -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-*-cp1251' -e /bin/bash &> /dev/null < /dev/null &
