#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
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
function lxc_ls()
{
	local STATUS;


	lxc ls -c n -f compact | sed -e 's/\ //g' | grep -v '^NAME$'
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function lxc_export()
{
	local STATUS;
	local FILE;


	while read -r NAME;
	do
		FILE="./${NAME}.tar";


		echo "lxc export ${NAME} ${FILE} --instance-only --compression=none;";
		lxc export ${NAME} ${FILE} --instance-only --compression=none &> /dev/null < /dev/null;
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			echo "ERROR: export was broken";
			return "${STATUS}";
		fi


# use ls -1 | repack --zstd
#		if [ "$(command -v zstd)" != "" ];
#		then
#			echo "zstd -C --ultra -22 --threads=0 -f -o ${FILE}.zst 2> /dev/null < ${FILE};";
#			zstd -C --ultra -22 --threads=0 -f -o "${FILE}.zst" 2> /dev/null < "${FILE}";
#			STATUS="${?}";
#			if [ "${STATUS}" != "0" ];
#			then
#				echo "ERROR: zstd pack was broken";
#				return "${STATUS}";
#			fi
#
#			echo "rm -rf ${FILE} &> /dev/null < /dev/null;";
#			rm -rf ${FILE} &> /dev/null < /dev/null;
#			STATUS="${?}";
#			if [ "${STATUS}" != "0" ];
#			then
#				echo "ERROR: rm was broken";
#				return "${STATUS}";
#			fi
#		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function lxc_import()
{
	local STATUS;


	while read -r FILE;
	do
		echo "lxc import ${FILE};";
		lxc import "${FILE}";
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			echo "ERROR: import was broken";
			return "${STATUS}";
		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function lxc_start()
{
	local STATUS;


	while read -r NAME;
	do
		echo "lxc start ${NAME};";
		lxc start ${NAME};
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			echo "ERROR: start was broken";
			return "${STATUS}";
		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function lxc_stop()
{
	local STATUS;


	while read -r NAME;
	do
		echo "lxc stop ${NAME};";
		lxc stop ${NAME};
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			echo "ERROR: stop was broken";
			return "${STATUS}";
		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# show help
function help()
{
	echo "example: ${1} [ ls | export | import | start | stop ]";
	echo "example: ${1} ls | ${1} export";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local STATUS;


	if [ "${OPERATION}" == "ls" ]
	then
		lxc_ls;
		STATUS="${?}";
		return "${STATUS}";
	fi

	if [ "${OPERATION}" == "export" ]
	then
		lxc_export;
		STATUS="${?}";
		return "${STATUS}";
	fi

	if [ "${OPERATION}" == "import" ]
	then
		lxc_import;
		STATUS="${?}";
		return "${STATUS}";
	fi

	if [ "${OPERATION}" == "start" ]
	then
		lxc_start;
		STATUS="${?}";
		return "${STATUS}";
	fi

	if [ "${OPERATION}" == "stop" ]
	then
		lxc_stop;
		STATUS="${?}";
		return "${STATUS}";
	fi


	help "${0}";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
