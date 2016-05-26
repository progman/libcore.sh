#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check run
function check_run()
{
	local PID_FILE="${1}" PID PID_SAVE PID_HASH PID_HASH_SAVE COL1 COL2;

	if [ "${PID_FILE}" == "" ];
	then
		return 0;
	fi

# check PID_SAVE and PID_HASH_SAVE
	if [ -e "${PID_FILE}" ];
	then
		read PID_SAVE < "${PID_FILE}";

		PID_HASH_SAVE='';
		if [ -e "${PID_FILE}.hash" ];
		then
			read PID_HASH_SAVE < "${PID_FILE}.hash";
		fi
		PID_HASH=$(shasum -a 1 <<< "${PID_SAVE}" | { read COL1 COL2; echo ${COL1}; });
		if [ "${PID_HASH}" != "${PID_HASH_SAVE}" ]
		then
			return 2; # program already run maybe (bad pid)
		fi

		if [ "$(ps -p ${PID_SAVE} | wc -l | { read COL1; echo ${COL1}; })" != "1" ];
		then
			return 1; # program already run (real)
		fi
	fi

# save PID
	PID="${BASHPID}";
	echo "${PID}" > "${PID_FILE}";
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;
		return 3; # program already run (did not save)
	fi

# save PID_HASH
	PID_HASH=$(shasum -a 1 <<< "${PID}" | { read COL1 COL2; echo ${COL1}; });
	echo "${PID_HASH}" > "${PID_FILE}.hash";
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

# read PID_HASH
	PID_HASH_SAVE='';
	if [ -e "${PID_FILE}.hash" ];
	then
		read PID_HASH_SAVE < "${PID_FILE}.hash";
	fi
	if [ "${PID_HASH_SAVE}" != "${PID_HASH}" ]
	then
		rm -rf -- "${PID_FILE}" &> /dev/null < /dev/null;
		return 3; # program already run (did not save)
	fi

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local SOURCE_DIR="${1}";
	local TARGET_DIR="${2}";
	local PID_FILE="${3}";
	local STATUS;


	if [ ! -d "${SOURCE_DIR}" ] || [ ! -d "${TARGET_DIR}" ];
	then
		echo "example: ${0} SOURCE_DIR TARGET_DIR [PID_FILE]";
		return 1;
	fi


# check depends tools
	check_prog "echo kill nice rsync shasum";
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


# let's go
	if [ "$(which ionice)" != "" ];
	then
#		ionice -c 3 nice -n 19 rsync -azLv --safe-links "${SOURCE_DIR}" "${TARGET_DIR}";
		ionice -c 3 nice -n 19 rsync -av --delete "${SOURCE_DIR}" "${TARGET_DIR}";
	else
#		nice -n 19 rsync -azLv --safe-links "${SOURCE_DIR}" "${TARGET_DIR}";
		nice -n 19 rsync -av --delete "${SOURCE_DIR}" "${TARGET_DIR}";
	fi


	return "${?}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
