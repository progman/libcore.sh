#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.5
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
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
	local LOG_FILE;


	if [ ! -f "${PROGRAM}" ];
	then
		echo "[make single process and] (re)load something program";
		echo "example (one   run, without log):                   PID_FILE=PID_FILE WORK_DIR=WORK_DIR                 ${0} PROGRAM [PROGRAM_ARGS] &> /dev/null < /dev/null &";
		echo "example (multi run, with auto log): FLAG_RELOAD='1' PID_FILE=PID_FILE WORK_DIR=WORK_DIR LOG_DIR=LOG_DIR ${0} PROGRAM [PROGRAM_ARGS] &> /dev/null < /dev/null &";
		echo "example (multi run, with file log): FLAG_RELOAD='1' PID_FILE=PID_FILE WORK_DIR=WORK_DIR                 ${0} PROGRAM [PROGRAM_ARGS] >> /var/log/program.log &";
		return 0;
	fi


# check depends tools
	check_prog "echo cat date kill nice ps rm touch wc";
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


# make log dir
	if [ "${LOG_DIR}" != "" ];
	then
		mkdir -p "${LOG_DIR}" &> /dev/null < /dev/null;
		STATUS="${?}";
		if [ "${STATUS}" == "1" ];
		then
			return 4; # log dir is invalid
		fi


		LOG_FILE=$(date '+%Y-%m-%d_%H-%M-%S.%N' | head -c 26);
		touch "${LOG_DIR}/${LOG_FILE}.log" &> /dev/null < /dev/null;
		ln -sf "${LOG_DIR}/${LOG_FILE}.log" "${LOG_DIR}/log" &> /dev/null < /dev/null;
	fi


# run
	while true;
	do

		if [ "${LOG_DIR}" != "" ];
		then
			"${@}" &> "${LOG_DIR}/${LOG_FILE}.log" < /dev/null;
			STATUS="${?}";
		else
			"${@}";
			STATUS="${?}";
		fi

		if [ "${FLAG_RELOAD}" != "1" ];
		then
			break;
		fi
	done


# remove pid file
	rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;


	return "${STATUS}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
