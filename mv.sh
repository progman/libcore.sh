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
# general function
function main()
{
# check minimal depends tools
	check_prog "echo mv";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ls -1 | ${0} [ DIR | --tmp [LIMIT] ]";
		return 1;
	fi


	if [ "${1}" == "--tmp" ] || [ "${1}" == "--tmp" ];
	then
		local LIMIT=50;
		if [ "${2}" != "" ];
		then
			LIMIT="${2}";
		fi

		if [ "${LIMIT}" != "0" ];
		then
			local OFFSET=0;
			local DIR;
			local FILE;
			while read -r FILE;
			do
				if [ "${OFFSET}" == "${LIMIT}" ];
				then
					OFFSET=0;
				fi

				if [ "${OFFSET}" == "0" ];
				then
					DIR=$(mktemp -d --tmpdir=./ 2> /dev/null);
					if [ "${?}" != "0" ];
					then
						echo "FATAL: can't make tmp dir";
						return 1;
					fi
				fi

				if [ -e "${FILE}" ];
				then
					mv "${FILE}" "${DIR}" &> /dev/null;
					echo "mv \"${FILE}\" ${DIR}";
					(( OFFSET++ ));
				fi
			done
		fi
	else
		if [ ! -d "${1}" ];
		then
			echo "FATAL: dir \"${1}\" not found...";
			return 1;
		fi

		local FILE;
		while read -r FILE;
		do
			if [ -e "${FILE}" ];
			then
				mv "${FILE}" "${1}" &> /dev/null;
				echo "mv \"${FILE}\" ${1}";
			fi
		done
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
