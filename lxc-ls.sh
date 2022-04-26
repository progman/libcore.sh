#!/bin/bash

lxc ls -c='n' | grep -v -- '--' | sed -e 's/|//g' | sed -e 's/\ //g' | grep -v 'NAME'
if [ "${?}" != "0" ];
then
	echo "ERROR";
	exit 1;
fi

exit 0;
