#!/bin/bash

if [ ! -f /tmp/FLAG_DISABLE_ALARM ];
then
	echo "alarm already on";
else
	rm -rf /tmp/FLAG_DISABLE_ALARM &> /dev/null;
	echo "alarm on";
fi
