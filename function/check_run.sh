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
