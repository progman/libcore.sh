#!/bin/bash

if [ ! -f /tmp/FLAG_DISABLE_ALARM ];
then
	touch /tmp/FLAG_DISABLE_ALARM;
	echo "alarm off";
else
	echo "alarm already off";
fi
