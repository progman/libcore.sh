#!/bin/bash

while true;
do

	if [ "$(ps -fe | grep "${1}" | grep -v grep | grep -v pwait)" == "0" ];
	then
		break;
	fi

	sleep 1;

done

exit 0;
