#!/bin/bash

if [ "${1}" == "" ] || [ ! -e "${1}" ];
then
	echo "example: ${0} FILE";
	exit 1;
fi

HASH=$(md5sum "${1}" | awk '{print $1}');

#EXT=$(echo "${1}" | sed -e 's/^[^\.]*//g');
EXT=$(echo "${1}" | sed -e 's/.*\.//g');

if [ "${1}" == "${EXT}" ];
then
	EXT="";
fi

NEW="${HASH}";
if [ "${EXT}" != "" ];
then
	NEW="${HASH}.${EXT}";
fi

echo "${NEW}";

if [ -e "${NEW}" ];
then
	exit 2;
fi

mv "${1}" "${NEW}";
if [ "${?}" != "0" ];
then
	exit 3;
fi

exit 0;


#TODO: fix name2hash /path/path/file
