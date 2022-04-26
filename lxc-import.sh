#!/bin/bash

while read -r NAME;
do
	lxc import ./${NAME}.tar* --instance-only;
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;
