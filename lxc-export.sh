#!/bin/bash

while read -r NAME;
do
	echo "lxc export ${NAME} ./${NAME}.tar.gz --instance-only";
	lxc export ${NAME} ./${NAME}.tar.gz --instance-only;
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;
