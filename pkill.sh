#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(command -v ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo ps grep awk kill";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


#	echo $$;
#	echo ${PPID};
#	sleep 100;

	SIGNAL="${1}"
	PROCESS="${2}"

	if [ "${SIGNAL}" == "" ];
	then
		echo "example: ${0} piter_mts";
		return 1;
	fi

	if [ "${PROCESS}" == "" ];
	then
		PROCESS=${SIGNAL}
		SIGNAL='-TERM'
	fi

#	echo "SIGNAL:${SIGNAL}"
#	echo "PROCESS:${PROCESS}"
#	return 0;

	for i in $(ps -fe | grep ${PROCESS} | awk '{print $2}');
	do
		if [ "${$}" == "${i}" ];
		then
			continue;
		fi

#		echo ${i};
		kill ${SIGNAL} ${i} &> /dev/null
#		kill ${SIGNAL} ${i}

	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
