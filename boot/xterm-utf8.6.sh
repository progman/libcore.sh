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

RESOLUTION=$(xrandr | grep -- '\*\+' | sed -e 's/^\ \ \ //g' | sed -e 's/\ .*//g');

#export COLUMNS=82;
#export LINES=60;

#source /tmp/env2
#xterm -geometry 84x56+0+0 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e /bin/bash &
#xterm -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -font '-cronyx-fixed-medium-r-normal-*-*-120-*-*-c-*-koi8-r' -e /bin/bash &> /dev/null < /dev/null &
#xterm &
#xterm -lc -class UXTerm -title uxterm -u8 -fa 'Terminus:12' &> /dev/null < /dev/null &
#xterm -lc -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr gray85 -bg gray13 -fg gray44 -hc gray75 -fa 'Terminus:pixelsize=14' &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'DroidSansMono:pixelsize=13' &> /dev/null < /dev/null &

if [ "${RESOLUTION}" = "1920x1080" ];
then
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+0+0   &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+0+360 &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+0+720 &> /dev/null < /dev/null &

	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+927+0   &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+927+360 &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 115x19+927+720 &> /dev/null < /dev/null &
else
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x32+0+0   &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x32+0+483 &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x31+0+966 &> /dev/null < /dev/null &

	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x32+1247+0   &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x32+1247+483 &> /dev/null < /dev/null &
	xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x31+1247+966 &> /dev/null < /dev/null &
fi

#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+0+0   &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+0+483 &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+0+966 &> /dev/null < /dev/null &

#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+1247+0   &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+1247+483 &> /dev/null < /dev/null &
#xterm -class UXTerm -title uxterm -u8 -sl 15000 -bc -cr yellow -bg black -fg orange -hc orange4 -fa 'Terminus:pixelsize=14' -geometry 155x26+1247+966 &> /dev/null < /dev/null &
