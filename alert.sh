#!/bin/bash

function alert()
{
	if [ "$(which xcalib)" != "" ];
	then

		for (( i=0; i < 3; i++ ));
		do
			xcalib -a -i;
			sleep 0.1;
			xcalib -a -i;
			sleep 0.1;
		done

	fi
}

alert;

exit 0;
