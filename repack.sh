#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.5
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
GLOBAL_FLAG_FOUND_GZIP=0;
GLOBAL_FLAG_FOUND_BZIP2=0;
GLOBAL_FLAG_FOUND_XZ=0;
GLOBAL_FLAG_FOUND_RAR=0;
GLOBAL_FLAG_FOUND_ZIP=0;
GLOBAL_FLAG_FOUND_ARJ=0;
GLOBAL_FLAG_FOUND_LHA=0;
GLOBAL_FLAG_FOUND_HA=0;
GLOBAL_FLAG_FOUND_7Z=0;
GLOBAL_DELTA_SIZE=0;
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
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check exist tools
function check_tool()
{
	if [ "$(which gzip)" != "" ];
	then
		GLOBAL_FLAG_FOUND_GZIP=1;
	fi

	if [ "$(which bzip2)" != "" ];
	then
		GLOBAL_FLAG_FOUND_BZIP2=1;
	fi

	if [ "$(which xz)" != "" ];
	then
		GLOBAL_FLAG_FOUND_XZ=1;
	fi

	if [ "$(which unrar)" != "" ];
	then
		GLOBAL_FLAG_FOUND_RAR=1;
	fi

	if [ "$(which unzip)" != "" ];
	then
		GLOBAL_FLAG_FOUND_ZIP=1;
	fi

	if [ "$(which arj)" != "" ];
	then
		GLOBAL_FLAG_FOUND_ARJ=1;
	fi

	if [ "$(which lha)" != "" ];
	then
		GLOBAL_FLAG_FOUND_LHA=1;
	fi

	if [ "$(which ha)" != "" ];
	then
		GLOBAL_FLAG_FOUND_HA=1;
	fi

	if [ "$(which 7z)" != "" ];
	then
		GLOBAL_FLAG_FOUND_7Z=1;
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# strip filename
function strip_filename()
{
	local SOURCE="${1}";
	local FILENAME;
	local OUT;

	while true;
	do
		FILENAME="${SOURCE}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[tT][aA][rR]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[gG][zZ]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[tT][gG][zZ]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[bB][zZ]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[bB][zZ]2$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[xX][zZ]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[rR][aA][rR]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[zZ][iI][pP]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[aA][rR][jJ]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[lL][hH][aA]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[hH][aA]$//g')";
		FILENAME="${OUT}";
		OUT="$(echo "${FILENAME}" | sed -e 's/\.[7][zZ]$//g')";
		FILENAME="${OUT}";

		if [ "${SOURCE}" == "${FILENAME}" ];
		then
			break;
		fi

		SOURCE="${FILENAME}";
	done

	echo "${SOURCE}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check file type
function check_file_type()
{
	local MIME="$(file -b -L --mime-type -- "${1}")";
#	echo "MIME: ${MIME}";


	if [ "${MIME}" == "application/x-tar" ];
	then
		echo "tar";
		return 0;
	fi

	if [ "${MIME}" == "application/gzip" ] || [ "${MIME}" == "application/x-compress" ];
	then
		if [ "GLOBAL_FLAG_FOUND_GZIP" == "0" ];
		then
			echo "gzip not found";
			return 1;
		fi

		echo "gz";
		return 0;
	fi

	if [ "${MIME}" == "application/x-bzip2" ];
	then
		if [ "GLOBAL_FLAG_FOUND_BZIP2" == "0" ];
		then
			echo "bzip2 not found";
			return 1;
		fi

		echo "bz2";
		return 0;
	fi

	if [ "${MIME}" == "application/x-xz" ];
	then
		if [ "GLOBAL_FLAG_FOUND_XZ" == "0" ];
		then
			echo "xz not found";
			return 1;
		fi

		echo "xz";
		return 0;
	fi

	if [ "${MIME}" == "application/x-rar" ];
	then
		if [ "GLOBAL_FLAG_FOUND_RAR" == "0" ];
		then
			echo "unrar not found";
			return 1;
		fi

		echo "rar";
		return 0;
	fi

	if [ "${MIME}" == "application/zip" ];
	then
		if [ "GLOBAL_FLAG_FOUND_ZIP" == "0" ];
		then
			echo "unzip not found";
			return 1;
		fi

		echo "zip";
		return 0;
	fi

	if [ "${MIME}" == "application/x-arj" ];
	then
		if [ "GLOBAL_FLAG_FOUND_ARJ" == "0" ];
		then
			echo "arj not found";
			return 1;
		fi

		echo "arj";
		return 0;
	fi

	if [ "${MIME}" == "application/x-lha" ];
	then
		if [ "GLOBAL_FLAG_FOUND_LHA" == "0" ];
		then
			echo "lha not found";
			return 1;
		fi

		echo "lha";
		return 0;
	fi

	if [ "${MIME}" == "application/x-7z-compressed" ];
	then
		if [ "GLOBAL_FLAG_FOUND_7Z" == "0" ];
		then
			echo "7z not found";
			return 1;
		fi

		echo "7z";
		return 0;
	fi

	if [ "${MIME}" == "application/octet-stream" ];
	then
		local MIMENAME="$(file -b -L -- "${1}")";

		if [ "$(echo ${MIMENAME} | grep '^RAR archive data' | wc -l)" != "0" ];
		then
			if [ "GLOBAL_FLAG_FOUND_RAR" == "0" ];
			then
				echo "unrar not found";
				return 1;
			fi

			echo "rar";
			return 0;
		fi

		if [ "$(echo ${MIMENAME} | grep '^Zip archive data' | wc -l)" != "0" ];
		then
			if [ "GLOBAL_FLAG_FOUND_ZIP" == "0" ];
			then
				echo "unzip not found";
				return 1;
			fi

			echo "zip";
			return 0;
		fi

		if [ "$(echo ${MIMENAME} | grep '^HA archive data' | wc -l)" != "0" ];
		then
			if [ "GLOBAL_FLAG_FOUND_HA" == "0" ];
			then
				echo "ha not found";
				return 1;
			fi

			echo "ha";
			return 0;
		fi
	fi


	echo "file not support type";
	return 1;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# correct suffix name, may be file is 'GZIP' and have suffix name is NOT '.gz'
function correct_suffix()
{
	local FILENAME="${1}";
	local DECOMPRESSOR="${2}";


	if [ ${#DECOMPRESSOR} -lt ${#FILENAME} ]; # strlen(DECOMPRESSOR) < strlen(FILENAME)
	then
		local OFFSET=${#FILENAME};
		(( OFFSET-=${#DECOMPRESSOR} ));
		local PART="${FILENAME:${OFFSET}}";

		if [ "${PART}" == "${DECOMPRESSOR}" ];
		then
			echo "${FILENAME}";
			return 0;
		fi
	fi


	mv -- "${FILENAME}" "${FILENAME}${DECOMPRESSOR}" &> /dev/null;
	echo "${FILENAME}${DECOMPRESSOR}";

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# unpack
function unpack()
{
	while true;
	do
		if [ "$(ls -1 | wc -l)" != "1" ];
		then
			break; # more one files
		fi


		local FILENAME="$(ls -1)";


# check file type
		local DECOMPRESSOR;
		DECOMPRESSOR="$(check_file_type "${FILENAME}")";
		if [ "${?}" != "0" ];
		then
#			echo "${DECOMPRESSOR}";
			break; # file not support type, pack
		fi


# set correct suffix name
		FILENAME="$(correct_suffix "${FILENAME}" ".${DECOMPRESSOR}")";


# unpack TAR
		if [ "${DECOMPRESSOR}" == "tar" ];
		then
			tar -xf "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "tar unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack GZIP
		if [ "${DECOMPRESSOR}" == "gz" ];
		then
			gzip -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "gzip unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack BZIP2
		if [ "${DECOMPRESSOR}" == "bz2" ];
		then
			bzip2 -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "bzip2 unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack XZ
		if [ "${DECOMPRESSOR}" == "xz" ];
		then
			xz -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "xz unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack RAR
		if [ "${DECOMPRESSOR}" == "rar" ];
		then
			unrar x -p' ' -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "unrar unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack ZIP
		if [ "${DECOMPRESSOR}" == "zip" ];
		then
			unzip -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "unzip unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack ARJ
		if [ "${DECOMPRESSOR}" == "arj" ];
		then
			arj x -y -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "arj unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack LHA
		if [ "${DECOMPRESSOR}" == "lha" ];
		then
			lha e "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "lha unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack HA
		if [ "${DECOMPRESSOR}" == "ha" ];
		then
			ha e "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ha unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack 7z
		if [ "${DECOMPRESSOR}" == "7z" ];
		then
			7z x -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "7z unpack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
				return 1;
			fi
			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


	done


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# repack file
function repack_file()
{
# check file exist
	if [ "${1}" == "" ];
	then
		echo "file not found";
		return 1;
	fi

	if [ -d "${1}" ];
	then
		echo "ignore, is dir";
		return 1;
	fi

	if [ -L "${1}" ];
	then
		echo "ignore, is link";
		return 1;
	fi

	if [ "${1}" == "" ] || [ ! -f "${1}" ];
	then
		echo "file not found";
		return 1;
	fi


# get size
	local SIZE_OLD=$(stat --printf '%s' -L -- "${1}");


# skip big files if set
	if [ "${REPACK_MAX_SIZE}" != "" ] && [ ${SIZE_OLD} -ge ${REPACK_MAX_SIZE} ]; # SIZE_OLD > REPACK_MAX_SIZE
	then
		local HSIZE_OLD="$(human_size ${SIZE_OLD})";
		local HREPACK_MAX_SIZE="$(human_size ${REPACK_MAX_SIZE})";
		echo "ignore, size(${HSIZE_OLD}) > REPACK_MAX_SIZE(${HREPACK_MAX_SIZE})";
		return 1;
	fi


# check file type
	local DECOMPRESSOR;
	DECOMPRESSOR="$(check_file_type "${1}")";
	if [ "${?}" != "0" ];
	then
		echo "${DECOMPRESSOR}";
		return 1;
	fi


	local SOURCE_FILENAME=$(basename -- "${1}");
#	echo "SOURCE_FILENAME: ${SOURCE_FILENAME}";


	local SOURCE_DIRNAME=$(dirname -- "${1}");
#	echo "SOURCE_DIRNAME: ${SOURCE_DIRNAME}";


# save work dir
	local DIR_CUR="${PWD}";


# go to source dir
	cd -- "${SOURCE_DIRNAME}";
	SOURCE_DIRNAME="${PWD}"; #get absolute path


# select compressor
	local COMPRESSOR;
	local FLAG_COMPRESSOR_SELECT=0;

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_XZ}" != "0" ];
	then
		COMPRESSOR="xz";
		FLAG_COMPRESSOR_SELECT=1;
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_BZIP2}" != "0" ];
	then
		COMPRESSOR="bz2";
		FLAG_COMPRESSOR_SELECT=1;
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_GZIP}" != "0" ];
	then
		COMPRESSOR="gz";
		FLAG_COMPRESSOR_SELECT=1;
	fi


# check exist file
	local TARGET_FILENAME="$(strip_filename "${SOURCE_FILENAME}").tar.${COMPRESSOR}";
#	echo "${SOURCE_FILENAME} -> ${TARGET_FILENAME}";

	if [ -e "${TARGET_FILENAME}" ] && [ "${TARGET_FILENAME}" != "${SOURCE_FILENAME}" ];
	then
		cd -- "${DIR_CUR}";
		echo "file already exist";
		return 1;
	fi


# create temp dir and files
	local REPACK_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		REPACK_TMPDIR="${TMPDIR}";
	fi


	if [ "${FLAG_USE_TMPDIR}" != "0" ];
	then
		FLAG_USE_TMPDIR=1;
	fi

	if [ "${FLAG_USE_TMPDIR}" == "0" ];
	then
		REPACK_TMPDIR="${SOURCE_DIRNAME}";
	fi


	local TMP1;
	TMP1="$(mktemp -d --tmpdir="${REPACK_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	local TMP2;
	TMP2="$(mktemp --tmpdir="${REPACK_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		return 1;
	fi

	local TMP3;
	TMP3="$(mktemp --tmpdir="${REPACK_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		rm -rf -- "${TMP2}";
		return 1;
	fi

	local TMP4;
	TMP4="$(mktemp --tmpdir="${REPACK_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		rm -rf -- "${TMP2}";
		rm -rf -- "${TMP3}";
		return 1;
	fi


	if [ "${FLAG_USE_TMPDIR}" == "0" ];
	then
		TMP1="${SOURCE_DIRNAME}/$(basename "${TMP1}")";
		TMP2="${SOURCE_DIRNAME}/$(basename "${TMP2}")";
		TMP3="${SOURCE_DIRNAME}/$(basename "${TMP3}")";
		TMP4="${SOURCE_DIRNAME}/$(basename "${TMP4}")";
	fi


#	echo "TMP1: \"${TMP1}\"";
#	echo "TMP2: \"${TMP2}\"";
#	echo "TMP3: \"${TMP3}\"";
#	echo "TMP4: \"${TMP4}\"";


# go to temp dir
	cd -- "${TMP1}";


# link to source file in tmp dir
	ln -sf "${SOURCE_DIRNAME}/${SOURCE_FILENAME}";


# unpack
	unpack;
	if [ "${?}" != "0" ];
	then
		cd -- "${DIR_CUR}";
		rm -rf -- "${TMP1}";
		rm -rf -- "${TMP2}";
		rm -rf -- "${TMP3}";
		rm -rf -- "${TMP4}";
		return 1;
	fi
	echo -n ".";


# make file list
	ls -1a | grep -v '^\.$\|^\.\.$' > "${TMP2}";

# add files to TAR
	while read -r i;
	do
		ionice -c 3 nice -n 19 tar -rf "${TMP3}" -- "${i}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " tar pack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
			cd -- "${SOURCE_DIRNAME}";
			rm -rf -- "${TMP1}";
			rm -rf -- "${TMP2}";
			rm -rf -- "${TMP3}";
			rm -rf -- "${TMP4}";
			cd -- "${DIR_CUR}";
			return 1;
		fi
	done < "${TMP2}";


	cd -- "${SOURCE_DIRNAME}";
	rm -rf -- "${TMP1}";
	rm -rf -- "${TMP2}";
	echo -n ".";


# compress TAR
	if [ "${COMPRESSOR}" == "xz" ];
	then
		if [ "${XZ_OPT}" == "" ];
		then
#			export XZ_OPT='-9 --extreme';
			export XZ_OPT='--lzma2=preset=9e,dict=1024MiB --memlimit-compress=7GiB';
		fi

		ionice -c 3 nice -n 19 xz -zc "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " xz pack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
			rm -rf -- "${TMP3}";
			rm -rf -- "${TMP4}";
			return 1;
		fi
	fi


	if [ "${COMPRESSOR}" == "bz2" ];
	then
		if [ "${BZIP2}" == "" ];
		then
			export BZIP2='-9';
		fi

		ionice -c 3 nice -n 19 bzip2 -zc "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " bzip2 pack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
			rm -rf -- "${TMP3}";
			rm -rf -- "${TMP4}";
			return 1;
		fi
	fi


	if [ "${COMPRESSOR}" == "gz" ];
	then
		if [ "${GZIP}" == "" ];
		then
			export GZIP='-9';
		fi

		ionice -c 3 nice -n 19 gzip -c "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " gzip pack error, FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
			rm -rf -- "${TMP3}";
			rm -rf -- "${TMP4}";
			return 1;
		fi
	fi


# kill TAR
	rm -rf -- "${TMP3}";
	echo -n ". ";


# check pack size
	local SIZE_NEW=$(stat --printf '%s' -L -- "${TMP4}");
	if [ ${SIZE_NEW} -ge ${SIZE_OLD} ] && [ "${FLAG_REPACK_FORCE}" != "1" ]; # if SIZE_NEW >= SIZE_OLD
	then
		rm -rf -- "${TMP4}";
		cd -- "${DIR_CUR}";
		echo "-0 B";
		return 0;
	fi


# view pack size
	local SIZE="${SIZE_NEW}";
	(( SIZE-=SIZE_OLD ));
	(( GLOBAL_DELTA_SIZE+=SIZE ));
	view_size "${SIZE}";


# set old time
	touch -r "${SOURCE_DIRNAME}/${SOURCE_FILENAME}" "${TMP4}";


# move pack
	mv -- "${TMP4}" "${TARGET_FILENAME}";


# delete old
	if [ "${TARGET_FILENAME}" != "${SOURCE_FILENAME}" ];
	then
		rm -rf -- "${SOURCE_FILENAME}";
	fi


# i'll be back
	cd -- "${DIR_CUR}";


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# repack filelist
function repack_filelist()
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
			local SIZE=$(stat --printf='%s' -L -- "${LINE}");
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

		repack_file "${LINE}";

		(( COUNT_CUR++ ));

	done < "${TMP2}";
	rm -rf -- "${TMP2}" &> /dev/null;


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# repack stdin
function repack_stdin()
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
			continue;
		fi

		if [ -L "${LINE}" ];
		then
			local FILE="$(readlink -f "${LINE}")";
			echo "${FILE}" >> "${TMP1}";
			continue;
		fi

# add file
		if [ -f "${LINE}" ];
		then
			echo "${LINE}" >> "${TMP1}";
			continue;
		fi
	done


	repack_filelist "${TMP1}";
	rm -rf -- "${TMP1}" &> /dev/null;


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local FILE_COUNT="${#}";
	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} [FILE|DIR]...";
		echo "example: cat FILELIST | ${0}";
		echo "vars:";
		echo -e "\tFLAG_USE_TMPDIR   : [0|1]";
		echo -e "\tFLAG_REPACK_FORCE : [0|1]";
		echo -e "\tREPACK_MAX_SIZE   : [SIZE]";
		return 1;
	fi


# check depends tools
	check_prog "basename dirname echo file find grep ionice ln ls mktemp mv nice printf readlink rm sed sort stat tar touch uniq wc which";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check compressors
	check_tool;
	if [ "${GLOBAL_FLAG_FOUND_GZIP}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_BZIP2}" == "0" ] && [ "${GLOBAL_FLAG_FOUND_XZ}" == "0" ];
	then
		echo "FATAL: install xz or bzip2 or gzip";
		return 1;
	fi


# repack stdin
	if [ "${FILE_COUNT}" == "0" ];
	then
		repack_stdin;

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
	repack_stdin < "${TMP1}";
	rm -rf -- "${TMP1}" &> /dev/null;

	echo -n "total: ";
	view_size "${GLOBAL_DELTA_SIZE}";

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
