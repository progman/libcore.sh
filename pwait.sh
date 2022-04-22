#!/bin/bash

while true;
do

	if [ "$(ps -fe | grep "${1}" | grep -v grep | grep -v pwait | wc -l | { read a b; echo ${a}; })" == "0" ];
	then
		break;
	fi

	sleep 1;

done

exit 0;
