#!/bin/bash

function do_lock()
{
	if [ "$(which i3lock)" != "" ];
	then
		i3lock -c 000000;
		return;
	fi

	if [ "$(which xlock)" != "" ];
	then
		xlock -mode blank -dpmsstandby 1 -dpmssuspend 1 -dpmsoff 1 +resetsaver;
		return;
	fi
}

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

sleep 0.5;
xset +dpms;
xset dpms force on;

do_lock;

xset s off;
xset -dpms;
