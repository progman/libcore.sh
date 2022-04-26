#!/bin/bash

while read -r NAME;
do
	lxc start ${NAME};
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;
