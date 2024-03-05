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
	check_prog "echo find file grep sed";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if  [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} [ DIR ]";
		return 0;
	fi


	local DIR;
	DIR='./';
	if [ "${1}" != "" ];
	then
		DIR="${1}";
	fi

	if [ ! -d "${DIR}" ];
	then
		echo "ERROR: dir ${DIR} is not found";
		return 1;
	fi


	find ${DIR} -type f -exec file -i {} \; | grep 'application/vnd.sqlite3' | sed -e 's/:.*//g';


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
