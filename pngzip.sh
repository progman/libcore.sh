#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.4
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
GLOBAL_DELTA_SIZE=0;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# convert SIZE to human readable string
function human_size()
{
	local SIZE="$(echo "${1}" | sed -e 's/^[-+]//g')";

	local SIGN="";
	if [ "${1:0:1}" == "-" ];
	then
		SIGN="-";
	fi


	if [ "$(which bc)" == "" ] || [ ${SIZE} -lt 1024 ]; # ${SIZE} < 1024
	then
		echo "${SIGN}${SIZE} B";
		return;
	fi


	local NAME=( "B" "kB" "MB" "GB" "TB" "PB" "EB" "ZB" "YB" );
	local NAME_INDEX=0;

	while true;
	do
		local EXPR="scale=1; ${SIZE} / (1024 ^ ${NAME_INDEX})";
		local X=$(echo "${EXPR}" | bc);
		local Y=$(echo "${X}" | sed -e 's/\..*//g');

		if [ ${Y} -lt 1024 ]; # ${Y} < 1024
		then
			break;
		fi

		(( NAME_INDEX++ ));
	done


	echo "${SIGN}${X} ${NAME[$NAME_INDEX]}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view human size
function view_size()
{
	local HUMAN_SIZE="$(human_size ${1})";

	if [ "${HUMAN_SIZE:0:1}" == "-" ];
	then
		echo "${HUMAN_SIZE}";
	else
		echo "+${HUMAN_SIZE}";
	fi
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# do file
function do_file()
{
	local TMP1;
	TMP1="$(mktemp --tmpdir="${REPACK_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi


	local FILE_TYPE=$(file -b -L --mime-type -- "${1}");
	if [ "${FILE_TYPE}" != "image/png" ];
	then
		echo "NOT PNG";
		return;
	fi


	local SIZE_OLD=$(stat --printf '%s' -- "${1}");

	pngcrush -brute -l 9 "${1}" "${TMP1}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "error repack";
		rm -rf -- "${TMP1}";
		return 1;
	fi

	local SIZE_NEW=$(stat --printf '%s' -- "${TMP1}");

	if [ ${SIZE_NEW} -ge ${SIZE_OLD} ]; # SIZE_NEW >= SIZE_OLD
	then
		echo "-0 B";
		rm -rf -- "${TMP1}";
		return 1;
	fi


# view pack size
	local SIZE="${SIZE_NEW}";
	(( SIZE-=SIZE_OLD ));
	(( GLOBAL_DELTA_SIZE+=SIZE ));
	view_size "${SIZE}";


	mv "${TMP1}" "${1}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# do filelist
function do_filelist()
{
	if [ "${1}" == "" ] || [ ! -f "${1}" ];
	then
		echo "file not found";
		return 1;
	fi


# create file for filelist
	local TMP1;
	TMP1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi


# create file for sorted filelist
	local TMP2;
	TMP2=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		rm -rf -- "${TMP1}" &> /dev/null;
		return 1;
	fi


# add in filelist exist files
	while read -r LINE;
	do
		if [ -f "${LINE}" ];
		then
			local SIZE=$(stat --printf='%s' -- "${LINE}");
			echo "${SIZE} ${LINE}" >> "${TMP1}";
		fi
	done < "${1}";


# sort filelist
	sort -n "${TMP1}" | sed -e 's/^[0-9]*\ //g' | uniq > "${TMP2}";
	rm -rf -- "${TMP1}" &> /dev/null;


# compute line count
	local COUNT_ALL=$(wc -l "${TMP2}" | { read a b; echo ${a}; });
	local COUNT_CUR=1;


# repack
	while read -r LINE;
	do
		printf "[%0${#COUNT_ALL}u/${COUNT_ALL}] \"${LINE}\": " "${COUNT_CUR}";

		do_file "${LINE}";

		(( COUNT_CUR++ ));

	done < "${TMP2}";
	rm -rf -- "${TMP2}" &> /dev/null;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# do stdin
function do_stdin()
{
# create file for filelist
	local TMP1;
	TMP1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi


# get current dir
	local DIR_CUR="${PWD}";


# create filelist
	while read -r LINE;
	do

# scan and add files in dir
		if [ -d "${LINE}" ];
		then
			cd -- "${LINE}";
			SOURCE_DIRNAME="${PWD}"; #get absolute path
			cd -- "${DIR_CUR}";
			find "${SOURCE_DIRNAME}" -type f >> "${TMP1}" 2> /dev/null;
		fi

# add file
		if [ -f "${LINE}" ];
		then
			echo "${LINE}" >> "${TMP1}";
		fi
	done


	do_filelist "${TMP1}";
	rm -rf -- "${TMP1}" &> /dev/null;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local FILE_COUNT="${#}";
	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} [FILE|DIR]...";
		echo "example: cat FILELIST | ${0}";
		return 1;
	fi


# check minimal depends tools
	check_prog "echo file find mktemp mv pngcrush printf rm sed sort stat uniq wc which";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check compressors
#	check_tool;
#	if [ "${GLOBAL_FLAG_FOUND_PNGCRUSH}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_OPTIPNG}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_PNGNQ}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_PNGQUANT}" == "0" ];
#	then
#		echo "FATAL: install pngcrush optipng pngnq pngquant";
#		return 1;
#	fi


# repack stdin
	if [ "${FILE_COUNT}" == "0" ];
	then
		do_stdin;

		echo -n "total: ";
		view_size "${GLOBAL_DELTA_SIZE}";

		return "${?}";
	fi


# create file for filelist
	local TMP1;
	TMP1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi


# create filelist
	while true;
	do
		echo "${1}" >> "${TMP1}";

		(( FILE_COUNT-- ));
		shift 1;

		if [ "${FILE_COUNT}" == "0" ];
		then
			break;
		fi
	done


# repack args
	do_stdin < "${TMP1}";
	rm -rf -- "${TMP1}" &> /dev/null;

	echo -n "total: ";
	view_size "${GLOBAL_DELTA_SIZE}";

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
