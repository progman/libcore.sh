#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.6
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
#TODO: fix name2hash /path/path/file
function do_it()
{
	local OLD="${1}";

	local HASH=$(sha3sum -a 224 "${OLD}" | { read a b; echo ${a}; });

#	local EXT=$(echo "${OLD}" | sed -e 's/^[^\.]*//g');
#	local EXT=$(echo "${OLD}" | sed -e 's/.*\.//g');
	local EXT=$(sed -e 's/.*\.//g' <<< "${OLD}");

	if [ "${OLD}" == "${EXT}" ];
	then
		EXT="";
	fi

	local NEW="${HASH}";
	if [ "${EXT}" != "" ];
	then
		NEW="${HASH}.${EXT}";
	fi

#	echo "${NEW}";

#	if [ -e "${NEW}" ];
#	then
#		return 2;
#	fi


	if [ "${OLD}" != "${NEW}" ];
	then
		mv -- "${OLD}" "${NEW}";
		if [ "${?}" != "0" ];
		then
			return 3;
		fi
		echo "${OLD}";
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
#	local FILE_COUNT="${#}";


	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: cat FILELIST | ${0}";
		return 1;
	fi


# check depends tools
	check_prog "echo sed sha3sum mv mktemp wc"; # sha3sum from libdigest-sha3-perl
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# do list
#	while true;
#	do
#		do_it "${1}";
#
#		(( FILE_COUNT-- ));
#		shift 1;
#
#		if [ "${FILE_COUNT}" == "0" ];
#		then
#			break;
#		fi
#	done


#	local TMP;
#	TMP=$(mktemp 2> /dev/null);


#	while read -r FILE;
#	do
#		echo "${FILE}" >> "${TMP}";
#	done


#	local COUNT_CUR=1;
#	local COUNT_ALL;
#	COUNT_ALL=$(wc -l "${TMP}" | { read a b; echo ${a}; });


# convert
	while read -r FILE;
	do
		if [ -e "${FILE}" ];
		then
#			echo "[${COUNT_CUR}/${COUNT_ALL}] ${FILE}";
			do_it "${FILE}";
			if [ "${?}" != "0" ];
			then
				return 1;
			fi
		fi

#		(( COUNT_CUR++ ));

#	done < "${TMP}";
	done;


#	rm -- -rf "${TMP}" &> /dev/null;


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
