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

#source /tmp/env2
#xterm -geometry 84x56+0+0 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e /bin/bash &
#xterm -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e /bin/bash &> /dev/null < /dev/null &
#xterm &
#xterm -lc -class UXTerm -title uxterm -u8 -fa 'Terminus:12' &> /dev/null < /dev/null &
#xterm -lc -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr gray85 -bg gray13 -fg gray44 -hc gray75 -fa 'Terminus:pixelsize=14' &> /dev/null < /dev/null &


#urxvt -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' &> /dev/null < /dev/null &
urxvt +sb -cr yellow -bg black -fg orange -hc orange4 -font '-*-terminus-medium-*-*-*-14-*-*-*-*-*-*' &> /dev/null < /dev/null &
