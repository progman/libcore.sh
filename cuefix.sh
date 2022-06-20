#!/bin/bash


CUE=${1};
if [ "${CUE}" == "" ];
then
	echo "example: ${0} CUE_FILE";
	exit 0;
fi


cat "${CUE}" | iconv -f cp1251 | tr -d '\r' | sed -e 's/\(:[0-9][0-9]$\)/\10/g' > "${CUE}.fix.cue";


exit 0;
