#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.3
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
# check run
function check_run()
{
	local PID_FILE="${1}" PID PID_SAVE COL1 COL2 LINE_COUNT;

	if [ "${PID_FILE}" == "" ];
	then
		return 0;
	fi

	if [ -f "${PID_FILE}" ];
	then
		LINE_COUNT=$(cat "${PID_FILE}" | wc -l | { read COL1 COL2; echo ${COL1}; }); # "PID" --> 0 line, maybe invalid save;  "PID\n" --> 1 line, valid save
		if [ "${LINE_COUNT}" != "1" ];
		then
			return 2; # program already run maybe (bad pid)
		fi

		read PID_SAVE < "${PID_FILE}";
		if [ "$(ps -p ${PID_SAVE} | wc -l | { read COL1; echo ${COL1}; })" != "1" ];
		then
			return 1; # program already run (real)
		fi
	fi

# save PID
	PID="${BASHPID}";
	echo "${PID}" &> "${PID_FILE}";
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;
		return 3; # program already run (did not save)
	fi

# read PID
	read PID_SAVE < "${PID_FILE}";
	if [ "${PID_SAVE}" != "${PID}" ]
	then
		rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;
		return 3; # program already run (did not save)
	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local PROGRAM="${1}";
	local STATUS;


	if [ ! -f "${PROGRAM}" ];
	then
		echo "[make single process and] run something program";
		echo "example: PID_FILE=PID_FILE ${0} PROGRAM [PROGRAM_ARGS]";
		echo "use in cron: PID_FILE=PID_FILE WORK_DIR=WORK_DIR ${0} PROGRAM [PROGRAM_ARGS] >> /var/log/program.log &";
		return 0;
	fi


# check depends tools
	check_prog "echo cat kill nice ps rm wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check run
	check_run "${PID_FILE}";
	STATUS="${?}";
	if [ "${STATUS}" == "1" ];
	then
		return 0; # program already run
	fi
	if [ "${STATUS}" == "2" ] || [ "${STATUS}" == "3" ];
	then
		echo "ERROR: corrupt PID file ${PID_FILE}";
		return "${STATUS}"; # bad pid file
	fi


	if [ "${WORK_DIR}" != "" ] && [ -d "${WORK_DIR}" ];
	then
		cd -- "${WORK_DIR}" &> /dev/null < /dev/null;
	fi


	"${@}";
	STATUS="${?}";


	rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;


	return "${STATUS}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
