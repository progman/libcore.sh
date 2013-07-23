#!/bin/sh

#echo $$;
#echo ${PPID};
#sleep 100;

SIGNAL="${1}"
PROCESS="${2}"

if [ "${SIGNAL}" == "" ];
then
	echo "example: ${0} piter_mts";
	exit 1;
fi

if [ "${PROCESS}" == "" ];
then
	PROCESS=${SIGNAL}
	SIGNAL='-TERM'
fi

#echo "SIGNAL:${SIGNAL}"
#echo "PROCESS:${PROCESS}"
#exit 0;

for i in $(ps -fe | grep ${PROCESS} | awk '{print $2}');
do

	if [ "${$}" == "${i}" ];
	then
		continue;
	fi

#	echo ${i};
	kill ${SIGNAL} ${i} &> /dev/null
#	kill ${SIGNAL} ${i}

done

exit 0;
