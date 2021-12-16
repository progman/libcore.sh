#!/bin/bash
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
function help()
{
	echo "example: ${0} DIR";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo git find";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	DIR='./';
	OLD_DIR=$(pwd);


	for i in $(find "${DIR}" -type d | grep .git$);
	do
		echo "${i}";


		cd -- "${i}" &> /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR";
			exit 1;
		fi


		git gc --aggressive --prune=now &> /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR";
			exit 1;
		fi


		cd -- "${OLD_DIR}" &> /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR";
			exit 1;
		fi
	done




	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
