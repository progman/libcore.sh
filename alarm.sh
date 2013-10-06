#!/bin/bash

if [ ! -f /tmp/FLAG_DISABLE_ALARM ];
then
	if [ "$(which beep)" != "" ];
	then
		beep -f 247 -l 62 -n -f 1 -l 53 -n -f 247 -l 62 -n -f 1 -l 53 -n -f 500 -l 62 -n -f 1 -l 49 -n -f 247 -l 65 -n -f 1 -l 54 -n -f 293 -l 63 -n -f 1 -l 171 -n -f 372 -l 62 -n -f 1 -l 54 -n -f 418 -l 62 -n -f 1 -l 55 -n -f 440 -l 62 -n -f 1 -l 171 -n -f 440 -l 61 -n -f 1 -l 171 -n -f 418 -l 122 -n -f 1 -l 346 -n -f 222 -l 64 -n -f 1 -l 53 -n -f 222 -l 63 -n -f 1 -l 55 -n -f 440 -l 61 -n -f 1 -l 55 -n -f 222 -l 60 -n -f 1 -l 55 -n -f 281 -l 62 -n -f 1 -l 171 -n -f 331 -l 64 -n -f 1 -l 55 -n -f 372 -l 63 -n -f 1 -l 53 -n -f 395 -l 63 -n -f 1 -l 167 -n -f 372 -l 62 -n -f 1 -l 54 -n -f 395 -l 62 -n -f 1 -l 55 -n -f 222 -l 61 -n -f 1 -l 55 -n -f 207 -l 63 -n -f 1 -l 53 -n -f 222 -l 64 -n -f 1 -l 169 -n -f 184 -l 65 -n -f 1 -l 53 -n -f 184 -l 62 -n -f 1 -l 53 -n -f 372 -l 63 -n -f 1 -l 52 -n -f 184 -l 63 -n -f 1 -l 54 -n -f 331 -l 60 -n -f 1 -l 171 -n -f 312 -l 61 -n -f 1 -l 53 -n -f 331 -l 61 -n -f 1 -l 54 -n -f 184 -l 63 -n -f 1 -l 170 -n -f 372 -l 60 -n -f 1 -l 170 -n -f 184 -l 121 -n -f 1 -l 343 -n -f 184 -l 62 -n -f 1 -l 54 -n -f 184 -l 64 -n -f 1 -l 54 -n -f 372 -l 62 -n -f 1 -l 54 -n -f 184 -l 62 -n -f 1 -l 53 -n -f 331 -l 61 -n -f 1 -l 170 -n -f 312 -l 62 -n -f 1 -l 54 -n -f 331 -l 61 -n -f 1 -l 54 -n -f 184 -l 63 -n -f 1 -l 171 -n -f 372 -l 62 -n -f 1 -l 171;
	fi
fi
