#!/bin/bash

echo "${@}" > /tmp/mplayer;

if [ "$(command -v mpv)" != "" ];
then
	mpv     "${@}" &> /dev/null < /dev/null &
else
	mplayer "${@}" &> /dev/null < /dev/null &
fi
