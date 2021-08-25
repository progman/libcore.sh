#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.4
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

		if [ "${2}" == "" ] || [ ! -e "${2}" ];
		then
			psql --host="${SQL_HOST}" --port="${SQL_PORT}" --dbname="${SQL_DATABASE}" --username="${SQL_LOGIN}" -w;
		else
			psql --host="${SQL_HOST}" --port="${SQL_PORT}" --dbname="${SQL_DATABASE}" --username="${SQL_LOGIN}" -w -f "${2}";
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

		if [ "${2}" == "" ] || [ ! -e "${2}" ];
		then
			mysql --host="${SQL_HOST}" --port="${SQL_PORT}" --database="${SQL_DATABASE}" --user="${SQL_LOGIN}";
		else
			mysql --host="${SQL_HOST}" --port="${SQL_PORT}" --database="${SQL_DATABASE}" --user="${SQL_LOGIN}" < "${2}";
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
