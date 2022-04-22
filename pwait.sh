#!/bin/bash

# local: pwait.sh 332004; alert.sh
# remote: ssh -o port=22 root@host 'pwait.sh 1145869'; alert.sh

while true;
do

	if [ "$(ps -fe | grep "${1}" | grep -v grep | grep -v pwait | wc -l | { read a b; echo ${a}; })" == "0" ];
	then
		break;
	fi

	sleep 1;

done

exit 0;
