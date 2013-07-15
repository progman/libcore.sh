#!/bin/bash

WINDOW='root';
if [ "${1}" != "" ];
then
	WINDOW="${1}";
fi

FILENAME="/tmp/screenshot-$(date '+%Y%m%d_%H%M%S').png";

import -window "${WINDOW}" "${FILENAME}";
