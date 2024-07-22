#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.8
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
# check var list
function var_check()
{
	if [ "${SQL_SERVER}" == "" ];
	then
		echo "FATAL: var \"SQL_SERVER\" is not set";
		return 1;
	fi

	if [ "${SQL_SERVER}" != "postgresql" ] && [ "${SQL_SERVER}" != "mysql" ];
	then
		echo "FATAL: var \"SQL_SERVER\" is not \"postgresql\" or \"mysql\"";
		return 1;
	fi

	if [ "${SQL_HOST}" == "" ];
	then
		echo "FATAL: var \"SQL_HOST\" is not set";
		return 1;
	fi

	if [ "${SQL_PORT}" == "" ];
	then
		echo "FATAL: var \"SQL_PORT\" is not set";
		return 1;
	fi

	if [ "${SQL_DATABASE}" == "" ];
	then
		echo "FATAL: var \"SQL_DATABASE\" is not set";
		return 1;
	fi

	if [ "${SQL_LOGIN}" == "" ];
	then
		echo "FATAL: var \"SQL_LOGIN\" is not set";
		return 1;
	fi

#	if [ "${SQL_PASSWORD}" == "" ]; # password can be empty
	if [ "$(env | grep SQL_PASSWORD | wc -l | { read a b; echo ${a}; })" == "0" ];
	then
		echo "FATAL: var \"SQL_PASSWORD\" is not set";
		return 1;
	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if  [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} ENV_FILE [ INPORT_FILE ]";
		return 0;
	fi


	if [ "${1}" != "" ] && [ -e "${1}" ];
	then
		source "${1}";
		export SQL_DUMP_DIR="${SQL_DUMP_DIR}";
		export SQL_DUMP_MAX_COUNT="${SQL_DUMP_MAX_COUNT}";
		export SQL_CONTAINER="${SQL_CONTAINER}";
		export SQL_SERVER="${SQL_SERVER}";
		export SQL_HOST="${SQL_HOST}";
		export SQL_PORT="${SQL_PORT}";
		export SQL_DATABASE="${SQL_DATABASE}";
		export SQL_LOGIN="${SQL_LOGIN}";
		export SQL_PASSWORD="${SQL_PASSWORD}";
	fi


	var_check;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# change title for xterm
	if [ "${TERM}" == "xterm" ];
	then
		echo -ne "\033]0;${SQL_LOGIN}@${SQL_HOST}:${SQL_PORT}/${SQL_DATABASE}\007";
	fi


	if [ "${SQL_SERVER}" == "postgresql" ];
	then
		check_prog "psql";
		if [ "${?}" != "0" ];
		then
			return 1;
		fi

		export PGPASSWORD="${SQL_PASSWORD}";

		local CMD="";
		if [ "${SQL_CONTAINER}" != "" ];
		then
			CMD+="docker exec -it ${SQL_CONTAINER} ";
		fi

		if [ "${2}" == "" ] || [ ! -e "${2}" ];
		then
			CMD+="psql";
			CMD+=" --host=${SQL_HOST}";
			CMD+=" --port=${SQL_PORT}";
			CMD+=" --dbname=${SQL_DATABASE}";
			CMD+=" --username=${SQL_LOGIN}";
			CMD+=" -w";

			if [ "${FLAG_DEBUG}" == "1" ];
			then
				echo "${CMD}";
			fi
			${CMD};
		else
			CMD+="psql";
			CMD+=" --host=${SQL_HOST}";
			CMD+=" --port=${SQL_PORT}";
			CMD+=" --dbname=${SQL_DATABASE}";
			CMD+=" --username=${SQL_LOGIN}";
			CMD+=" -w -f ${2}";

			if [ "${FLAG_DEBUG}" == "1" ];
			then
				echo "${CMD}";
			fi
			${CMD};
		fi
	fi


	if [ "${SQL_SERVER}" == "mysql" ];
	then
		check_prog "mysql";
		if [ "${?}" != "0" ];
		then
			return 1;
		fi

		export MYSQL_PWD="${SQL_PASSWORD}";

		local CMD="";
		if [ "${SQL_CONTAINER}" != "" ];
		then
			CMD+="docker exec -it ${SQL_CONTAINER} ";
		fi

		if [ "${2}" == "" ] || [ ! -e "${2}" ];
		then
			CMD+="mysql";
			CMD+=" --host=${SQL_HOST}";
			CMD+=" --port=${SQL_PORT}";
			CMD+=" --database=${SQL_DATABASE}";
			CMD+=" --user=${SQL_LOGIN}";

			if [ "${FLAG_DEBUG}" == "1" ];
			then
				echo "${CMD}";
			fi
			${CMD};
		else
			CMD+="mysql";
			CMD+=" --host=${SQL_HOST}";
			CMD+=" --port=${SQL_PORT}";
			CMD+=" --database=${SQL_DATABASE}";
			CMD+=" --user=${SQL_LOGIN}";

			if [ "${FLAG_DEBUG}" == "1" ];
			then
				echo "${CMD}";
			fi
			${CMD} < "${2}";
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
