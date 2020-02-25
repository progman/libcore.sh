#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function check_run_paranoid()
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
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
