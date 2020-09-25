#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
# git clone git://github.com/progman/git_backup.git
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "$(get_time)! FATAL: you must install \"${i}\", exit";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# keep N new files and kill other
function kill_ring()
{
	local MAX_ITEM_COUNT="${1}";
	(( MAX_ITEM_COUNT+=0 ))
	local FLAG_GNU;
	local COL1;


	if [ "${MAX_ITEM_COUNT}" == "0" ]; # 0 is disable
	then
		return;
	fi


	FLAG_GNU=$(find --version 2>&1 | grep GNU | wc -l | { read COL1; echo ${COL1}; });

	if [ "${FLAG_GNU}" != "0" ];
	then
		local FILENAME;
#		find ./ -maxdepth 1 -type f -iname '*\.tar\.*' -printf '%T@ %p\n' | sort -nr | sed -e 's/^[0-9]*\.[0-9]*\ \.\///g' |
		find ./ -maxdepth 1 -type f -iname '*'         -printf '%T@ %p\n' | sort -nr | sed -e 's/^[0-9]*\.[0-9]*\ \.\///g' |
		{
			while read -r FILENAME;
			do
				if [ "${MAX_ITEM_COUNT}" == "0" ];
				then
					echo "rm -rf \"${FILENAME}\"";
					rm -rf -- "${FILENAME}" &> /dev/null;
					continue;
				fi

				(( MAX_ITEM_COUNT-- ));
			done
		};
		return;
	fi


	local FILENAME1;
	local FILENAME2;
#	find ./ -maxdepth 1 -type f -iname '*\.tar\.*' |
	find ./ -maxdepth 1 -type f -iname '*'         |
	{
		while read -r FILENAME1;
		do
			stat -f '%m %N' "${FILENAME1}";
		done
	} | sort -nr | sed -e 's/^[0-9]*\ \.\///g' |
	{
		while read -r FILENAME2;
		do
			if [ "${MAX_ITEM_COUNT}" == "0" ];
			then
				echo "rm -rf \"${FILENAME2}\"";
				rm -rf -- "${FILENAME2}" &> /dev/null;
				continue;
			fi

			(( MAX_ITEM_COUNT-- ));
		done
	};
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local STATUS;


	local ARGC="${#}";
	if [ "${ARGC}" != "2" ];
	then
		echo "example: ${0} FILE_COUNT DIR";
		return 1;
	fi
	local FILE_COUNT="${1}";
	local DIR="${2}";


# check minimal depends tools
	check_prog "echo ps wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ ! -d "${DIR}" ];
	then
		echo "ERROR: dir is not found";
		return 1;
	fi


	cd -- "${DIR}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: dir is not changed";
		return 1;
	fi


	kill_ring "${FILE_COUNT}" &> /dev/null;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
