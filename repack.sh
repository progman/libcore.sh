#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
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
# check exist compressors
function check_compressor()
{
	FLAG_FOUND_GZIP=0;
	FLAG_FOUND_BZIP2=0;
	FLAG_FOUND_XZ=0;

	if [ "$(which gzip)" != "" ];
	then
		FLAG_FOUND_GZIP=1;
	fi

	if [ "$(which bzip2)" != "" ];
	then
		FLAG_FOUND_BZIP2=1;
	fi

	if [ "$(which xz)" != "" ];
	then
		FLAG_FOUND_XZ=1;
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
#	local MIME="$(file -L --mime-type "${1}" | sed -e 's/.*\ //g')";
	local MIME="$(file -b -L --mime-type -- "${1}")";
#	echo "MIME: ${MIME}";

	FLAG_TAR=0;
	FLAG_GZIP=0;
	FLAG_BZIP2=0;
	FLAG_XZ=0;
	FLAG_RAR=0;
	FLAG_ZIP=0;
	FLAG_ARJ=0;
	FLAG_LHA=0;
	FLAG_HA=0;


	if [ "${MIME}" == "application/x-tar" ];
	then
		FLAG_TAR=1;
		EXT="tar";
#		echo "INFO: TAR DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/gzip" ] || [ "${MIME}" == "application/x-compress" ];
	then
		FLAG_GZIP=1;
		EXT="gz";
#		echo "INFO: GZIP DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/x-bzip2" ];
	then
		FLAG_BZIP2=1;
		EXT="bz2";
#		echo "INFO: BZIP2 DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/x-xz" ];
	then
		FLAG_XZ=1;
		EXT="xz";
#		echo "INFO: XZ DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/x-rar" ];
	then
		FLAG_RAR=1;
		EXT="rar";
#		echo "INFO: RAR DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/zip" ];
	then
		FLAG_ZIP=1;
		EXT="zip";
#		echo "INFO: ZIP DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/x-arj" ];
	then
		FLAG_ARJ=1;
		EXT="arj";
#		echo "INFO: ARJ DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/x-lha" ];
	then
		FLAG_LHA=1;
		EXT="lha";
#		echo "INFO: LHA DETECT";
		return 0;
	fi

	if [ "${MIME}" == "application/octet-stream" ];
	then
		local MIMENAME="$(file -b -L -- "${1}")";

		if [ "$(echo ${MIMENAME} | grep '^HA archive data' | wc -l)" != "0" ];
		then
			FLAG_HA=1;
			EXT="ha";
#			echo "INFO: HA DETECT";
			return 0;
		fi
	fi


	return 1;
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


		FILENAME="$(ls -1)";


# check file type
		check_file_type "${FILENAME}";
		if [ "${?}" != "0" ];
		then
			break; # file not support type, pack
		fi


# set correct suffix name
# example may be file is 'GZIP' and have suffix name is NOT '.gz'
		mv -- "${FILENAME}" "${FILENAME}.${EXT}";
		FILENAME_OLD="${FILENAME}";
		FILENAME="${FILENAME}.${EXT}";


# unpack TAR
		if [ "${FLAG_TAR}" == "1" ];
		then
			tar -xf "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "tar unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack GZIP
		if [ "${FLAG_GZIP}" == "1" ];
		then
			if [ "${FLAG_FOUND_GZIP}" == "0" ];
			then
				echo "gzip not found";
				return 1;
			fi

			gzip -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "gzip unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack BZIP2
		if [ "${FLAG_BZIP2}" == "1" ];
		then
			if [ "${FLAG_FOUND_BZIP2}" == "0" ];
			then
				echo "bzip2 not found";
				return 1;
			fi

			bzip2 -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "bzip2 unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack XZ
		if [ "${FLAG_XZ}" == "1" ];
		then
			if [ "${FLAG_FOUND_XZ}" == "0" ];
			then
				echo "xz not found";
				return 1;
			fi

			xz -df -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "xz unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack RAR
		if [ "${FLAG_RAR}" == "1" ];
		then
			if [ "$(which unrar)" == "" ];
			then
				echo "unrar not found";
				return 1;
			fi

			unrar x -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "unrar unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack ZIP
		if [ "${FLAG_ZIP}" == "1" ];
		then
			if [ "$(which unzip)" == "" ];
			then
				echo "unzip not found";
				return 1;
			fi

			unzip -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "unzip unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack ARJ
		if [ "${FLAG_ARJ}" == "1" ];
		then
			if [ "$(which arj)" == "" ];
			then
				echo "arj not found";
				return 1;
			fi

			arj x -- "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "arj unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack LHA
		if [ "${FLAG_LHA}" == "1" ];
		then
			if [ "$(which lha)" == "" ];
			then
				echo "lha not found";
				return 1;
			fi

			lha e "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "lha unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


# unpack HA
		if [ "${FLAG_HA}" == "1" ];
		then
			if [ "$(which ha)" == "" ];
			then
				echo "ha not found";
				return 1;
			fi

			ha e "${FILENAME}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ha unpack error";
				return 1;
			fi

			rm -rf -- "${FILENAME}" &> /dev/null;
		fi


	done


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# repack file
function repack()
{
# check file exist
	if [ "${1}" == "" ];
	then
		echo "file not found";
		return 1;
	fi

	if [ -d "${1}" ];
	then
		echo "is dir";
		return 1;
	fi

	if [ "${1}" == "" ] || [ ! -f "${1}" ];
	then
		echo "file not found";
		return 1;
	fi


# check file type
	check_file_type "${1}";
	if [ "${?}" != "0" ];
	then
		echo "file not support type";
		return 1;
	fi


	SIZE_OLD=$(stat --printf '%s' -- "${1}");


	SOURCE_FILENAME=$(basename -- "${1}");
#	echo "SOURCE_FILENAME: ${SOURCE_FILENAME}";


	SOURCE_DIRNAME=$(dirname -- "${1}");
#	echo "SOURCE_DIRNAME: ${SOURCE_DIRNAME}";


# save work dir
	DIR_CUR="${PWD}";


# go to source dir
	cd -- "${SOURCE_DIRNAME}";
	SOURCE_DIRNAME="${PWD}"; #get absolute path


# select compressor
	local FLAG_COMPRESSOR_SELECT=0;
	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${FLAG_FOUND_XZ}" != "0" ];
	then
		COMPRESSOR="xz";
		FLAG_COMPRESSOR_SELECT=1;
	fi


	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${FLAG_FOUND_BZIP2}" != "0" ];
	then
		COMPRESSOR="bz2";
		FLAG_COMPRESSOR_SELECT=1;
	fi


	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "${FLAG_FOUND_GZIP}" != "0" ];
	then
		COMPRESSOR="gz";
		FLAG_COMPRESSOR_SELECT=1;
	fi


# check exist file
	TARGET_FILENAME="$(strip_filename "${SOURCE_FILENAME}").tar.${COMPRESSOR}";
#	echo "${SOURCE_FILENAME} -> ${TARGET_FILENAME}";

	if [ -e "${TARGET_FILENAME}" ] && [ "${TARGET_FILENAME}" != "${SOURCE_FILENAME}" ];
	then
		rm -rf -- "${TMP4}";
		cd -- "${DIR_CUR}";
		echo "file already exist";
		return 1;
	fi


# create temp dir and files
	REPACK_TMPDIR="/tmp";
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


	TMP1="$(mktemp -d --tmpdir="${REPACK_TMPDIR}")";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	TMP2="$(mktemp --tmpdir="${REPACK_TMPDIR}")";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		return 1;
	fi

	TMP3="$(mktemp --tmpdir="${REPACK_TMPDIR}")";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		rm -rf -- "${TMP2}";
		return 1;
	fi

	TMP4="$(mktemp --tmpdir="${REPACK_TMPDIR}")";
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
	ls -1 > "${TMP2}";


# add files to TAR
	while read -r i;
	do
		ionice -c 3 nice -n 20 tar -rf "${TMP3}" -- "${i}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " tar error (may be pack dir is full), FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
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
			export XZ_OPT='--lzma2=preset=9e,dict=512MiB';
		fi

		ionice -c 3 nice -n 20 xz -zc "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " xz error (may be pack dir is full), FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
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

		ionice -c 3 nice -n 20 bzip2 -zc "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " bzip2 error (may be pack dir is full), FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
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

		ionice -c 3 nice -n 20 gzip -c "${TMP3}" > "${TMP4}" 2> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " gzip error (may be pack dir is full), FLAG_USE_TMPDIR=${FLAG_USE_TMPDIR}";
			rm -rf -- "${TMP3}";
			rm -rf -- "${TMP4}";
			return 1;
		fi
	fi


# kill TAR
	rm -rf -- "${TMP3}";
	echo -n ". ";


# check pack size
	SIZE_NEW=$(stat --printf '%s' -- "${TMP4}");
	if [ ${SIZE_NEW} -ge ${SIZE_OLD} ] && [ "${FLAG_REPACK_FORCE}" != "1" ]; # if SIZE_NEW >= SIZE_OLD
	then
		rm -rf -- "${TMP4}";
		cd -- "${DIR_CUR}";
		echo "-0 B";
		return 0;
	fi


# view pack size
	SIZE="${SIZE_NEW}";
	(( SIZE-=SIZE_OLD ));

	HUMAN_SIZE="$(human_size ${SIZE})";

	if [ "${HUMAN_SIZE:0:1}" == "-" ];
	then
		echo "${HUMAN_SIZE}";
	else
		echo "+${HUMAN_SIZE}";
	fi


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
# general function
function main()
{
	FILE_COUNT="${#}";
	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} FILE...";
		echo "example: cat FILELIST | ${0}";
		return 1;
	fi


# check minimal depends tools
	check_prog "basename dirname echo file ionice ln ls mktemp mv nice rm sed stat tar wc which";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check compressor
	check_compressor;
	if [ "${FLAG_FOUND_GZIP}" == "0" ] && [ "${FLAG_FOUND_BZIP2}" == "0" ] && [ "${FLAG_FOUND_XZ}" == "0" ];
	then
		echo "FATAL: install xz or bzip2 or gzip";
		return 1;
	fi


# file repack
	if [ "${FILE_COUNT}" != "0" ];
	then
		while true;
		do
			echo -n "\"${1}\": ";
			repack "${1}";

			(( FILE_COUNT-- ));
			shift 1;

			if [ "${FILE_COUNT}" == "0" ];
			then
				break;
			fi
		done

		return 0;
	fi


# filelist repack

# create file for filelist
	TMP1=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi

# create file for sorted filelist
	TMP2=$(mktemp);
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
			SIZE=$(stat --printf='%s' -- "${LINE}");
			echo "${SIZE} ${LINE}" >> "${TMP1}";
		fi
	done


# sort filelist
	sort -n "${TMP1}" | sed -e 's/^[0-9]*\ //g' > "${TMP2}";
	rm -rf -- "${TMP1}" &> /dev/null;


# compute line count
	COUNT_ALL=$(wc -l "${TMP2}" | { read a b; echo ${a}; });
	COUNT_CUR=1;

# repack
	while read -r LINE;
	do
		echo -n "[${COUNT_CUR}/${COUNT_ALL}] \"${LINE}\": ";

		repack "${LINE}";

		(( COUNT_CUR++ ));

	done < "${TMP2}";
	rm -rf -- "${TMP2}" &> /dev/null;


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
