#!/bin/bash

# echo "alias tn='. tn.sh'" >> ~/.bashrc


X=0;
LAST=$(find /tmp/ -maxdepth 1 -type d -iname '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]' 2> /dev/null | sort -nr | head -n 1 | sed -e 's/.*\///g' | sed -e 's/^0*//g');

if [ "${LAST}" != "" ];
then
	X="${LAST}";
	(( X++ ));
else
	Y=$(printf "/tmp/%08u" ${X});
	if [ -e "${Y}" ];
	then
		(( X++ ));
	fi
fi

Y=$(printf "/tmp/%08u" ${X});
mkdir "${Y}";
cd "${Y}";
