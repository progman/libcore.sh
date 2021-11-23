#!/bin/bash

if [ ! -f /tmp/FLAG_DISABLE_ALARM ];
then
	touch /tmp/FLAG_DISABLE_ALARM;
	echo "alarm off";
	echo "$(date '+%Y-%m-%d %H:%M:%S.%N'): alarm off" >> /tmp/alarm.log;
else
	echo "alarm already off";
	echo "$(date '+%Y-%m-%d %H:%M:%S.%N'): alarm already off" >> /tmp/alarm.log;
fi
