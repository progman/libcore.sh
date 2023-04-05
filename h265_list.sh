#!/bin/bash

function convert()
{
	local FILE;
	FILE="${1}";
	h265.sh "${FILE}" "${FILE}.mkv" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: broken convert file \"${FILE}\"";
		exit 1;
	fi
}

while read -r LINE;
do
	echo "${LINE}";
	convert "${LINE}";
done;

exit 0;
