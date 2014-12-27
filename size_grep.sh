#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
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
# show help
function help()
{
	echo "example: ls -1 | ${1} [ '<=' | '<' | '>' | '>=' | '==' | '!=' ] SIZE";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local SIZE="${2}";


	if [ "${OPERATION}" == "" ] || [ "${SIZE}" == "" ];
	then
		help "${0}";
		return 1;
	fi


	if [ "${OPERATION}" != "<=" ] && [ "${OPERATION}" != "<" ] && [ "${OPERATION}" != ">" ] && [ "${OPERATION}" != ">=" ] && [ "${OPERATION}" != "==" ] && [ "${OPERATION}" != "!=" ];
	then
		help "${0}";
		return 1;
	fi


# check depends tools
	check_prog "echo stat";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	local SIZE_FILE;
	while read -r LINE;
	do
		SIZE_FILE=$(stat --printf '%s' -L -- "${LINE}" 2> /dev/null);
		if [ "${?}" != "0" ];
		then
			continue;
		fi

		if [ "${OPERATION}" == "<=" ];
		then
			if [ "${SIZE_FILE}" -le "${SIZE}" ]; # INTEGER1 is less than or equal to INTEGER2
			then
				echo "${LINE}";
			fi
		fi

		if [ "${OPERATION}" == "<" ];
		then
			if [ "${SIZE_FILE}" -lt "${SIZE}" ]; # INTEGER1 is less than INTEGER2
			then
				echo "${LINE}";
			fi
		fi

		if [ "${OPERATION}" == ">" ];
		then
			if [ "${SIZE_FILE}" -gt "${SIZE}" ]; # INTEGER1 is greater than INTEGER2
			then
				echo "${LINE}";
			fi
		fi

		if [ "${OPERATION}" == ">=" ];
		then
			if [ "${SIZE_FILE}" -ge "${SIZE}" ]; # INTEGER1 is greater than or equal to INTEGER2
			then
				echo "${LINE}";
			fi
		fi

		if [ "${OPERATION}" == "==" ];
		then
			if [ "${SIZE_FILE}" -eq "${SIZE}" ]; # INTEGER1 is equal to INTEGER2
			then
				echo "${LINE}";
			fi
		fi

		if [ "${OPERATION}" == "!=" ];
		then
			if [ "${SIZE_FILE}" -ne "${SIZE}" ]; # INTEGER1 is not equal to INTEGER2
			then
				echo "${LINE}";
			fi
		fi

	done


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
