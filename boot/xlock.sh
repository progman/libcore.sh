#!/bin/bash

function do_lock()
{
	if [ "$(command -v i3lock)" != "" ];
	then
		i3lock -c 000000 -n;
		return;
	fi

	if [ "$(command -v xlock)" != "" ];
	then
		xlock -mode blank -dpmsstandby 1 -dpmssuspend 1 -dpmsoff 1 +resetsaver;
		return;
	fi
}


# turn on ENGLISH
#LAYOUT=$(setxkbmap -print -verbose 10 | grep layout | sed -e 's/.*\ //g');
#if [ "${LAYOUT}" == "us,ru" ];
#then
#	setxkbmap -layout us; sleep 0.1; setxkbmap -layout us,ru;
#fi


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

sleep 0.3;
xset s off;

xset +dpms;
xset +dpms dpms 5 5 5;
xset dpms force off;

do_lock;

xset dpms force on;
xset +dpms dpms 0 0 0;
xset -dpms;
