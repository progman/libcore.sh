#!/bin/bash

WINDOW='root';
if [ "${1}" != "" ];
then
	WINDOW="${1}";
fi

FILENAME="/tmp/screenshot-$(date '+%Y%m%d_%H%M%S').png";


if [ "$(which import)" == "" ];
then
	echo "ERROR: imagemagick not found";
	exit 1;
fi


import -window "${WINDOW}" "${FILENAME}";


if [ "$(which pngcrush)" != "" ];
then
	TMP="$(mktemp)";
	pngcrush -brute -l 9 "${FILENAME}" "${TMP}" &> /dev/null;
	if [ "${?}" == "0" ];
	then
		mv "${TMP}" "${FILENAME}";
	else
		rm -rf "${TMP}";
	fi
fi

if [ "$(which beep)" != "" ];
then
	beep;
fi

exit 0;
