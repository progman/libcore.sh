#!/bin/bash

while read -r NAME;
do
	echo "lxc import ./${NAME}.tar*";
	lxc import ./${NAME}.tar*;
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;
