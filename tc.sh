#!/bin/bash

# echo "alias tc='. tc.sh'" >> ~/.bashrc


X=0;
LAST=$(find /tmp/ -type d -iname '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' | sort -nr | head -n 1 | sed -e 's/.*\///g' | sed -e 's/^0*//g');

if [ "${LAST}" != "" ];
then
	X="${LAST}";
	Y=$(printf "/tmp/%08u" ${X});
else
	Y=$(printf "/tmp/%08u" ${X});
	if [ ! -e "${Y}" ];
	then
		mkdir "${Y}";
	fi
fi

cd "${Y}";
