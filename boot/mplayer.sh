#!/bin/bash

echo "${@}" > /tmp/mplayer;

if [ "$(which mpv)" != "" ];
then
	mpv     "${@}" &> /dev/null < /dev/null &
else
	mplayer "${@}" &> /dev/null < /dev/null &
fi
