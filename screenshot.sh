#!/bin/bash

WINDOW='root';
if [ "${1}" != "" ];
then
	WINDOW="${1}";
fi

FILENAME="/tmp/screenshot-$(date '+%Y%m%d_%H%M%S').png";

import -window "${WINDOW}" "${FILENAME}";


if [ "$(which pngcrush)" != "" ];
then
	TMP="$(mktemp)";
	pngcrush -brute "${FILENAME}" "${TMP}";
	if [ "${?}" == "0" ];
	then
		mv "${TMP}" "${FILENAME}";
	else
		rm -rf "${TMP}";
	fi
fi
