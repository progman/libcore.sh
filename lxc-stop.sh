#!/bin/bash

while read -r NAME;
do
	echo "lxc stop ${NAME}";
	lxc stop ${NAME};
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;
