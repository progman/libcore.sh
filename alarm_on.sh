#!/bin/bash

if [ ! -f /tmp/FLAG_DISABLE_ALARM ];
then
	echo "alarm already on";
	echo "$(date '+%Y-%m-%d %H:%M:%S.%N'): alarm already on" >> /tmp/alarm.log;
else
	rm -rf /tmp/FLAG_DISABLE_ALARM &> /dev/null;
	echo "alarm on";
	echo "$(date '+%Y-%m-%d %H:%M:%S.%N'): alarm on" >> /tmp/alarm.log;
fi
