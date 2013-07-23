#!/bin/sh

if [ "${UID}" != "0" ];
then
	echo "You NOT root !";
	exit 1;
fi

if [ "${1}" == "" ];
then
	echo "example: prenice -20 bash"
	exit 1;
fi
if [ "${2}" == "" ];
then
	echo "example: prenice -20 bash"
	exit 1;
fi


for PID in `ps -A | grep "${2}" | awk '{print $1}'`;
do
	renice "${1}" "${PID}";
done

exit 0;
