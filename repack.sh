#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	local FLAG_OK=1;
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			FLAG_OK=0;
			break;
		fi
	done

	return ${FLAG_OK};
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
	SOURCE="${1}";
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

		if [ "${SOURCE}" == "${FILENAME}" ];
		then
			break;
		fi

		SOURCE="${FILENAME}";
	done
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check file type
function check_file_type()
{
	local MIME="$(file -L --mime-type "${1}" | sed -e 's/.*\ //g')";
#	echo "MIME: ${MIME}";

	FLAG_TAR=0;
	FLAG_GZIP=0;
	FLAG_BZIP2=0;
	FLAG_XZ=0;
	FLAG_RAR=0;
	FLAG_ZIP=0;
	FLAG_ARJ=0;


	if [ "${MIME}" == "application/x-tar" ];
	then
		FLAG_TAR=1;
		EXT="tar";
#		echo "INFO: TAR DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/gzip" ];
	then
		FLAG_GZIP=1;
		EXT="gz";
#		echo "INFO: GZIP DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/x-bzip2" ];
	then
		FLAG_BZIP2=1;
		EXT="bz2";
#		echo "INFO: BZIP2 DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/x-xz" ];
	then
		FLAG_XZ=1;
		EXT="xz";
#		echo "INFO: XZ DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/x-rar" ];
	then
		FLAG_RAR=1;
		EXT="rar";
#		echo "INFO: RAR DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/zip" ];
	then
		FLAG_ZIP=1;
		EXT="zip";
#		echo "INFO: ZIP DETECT";
		return 1;
	fi

	if [ "${MIME}" == "application/x-arj" ];
	then
		FLAG_ARJ=1;
		EXT="arj";
#		echo "INFO: ARJ DETECT";
		return 1;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# unpack
function unpack()
{
	FLAG_OK=0;

	while true;
	do
#echo "----------------";
#ls -1;

		if [ "$(ls -1 | wc -l)" != "1" ];
		then
#			echo "INFO: more one files";
			FLAG_OK=1; # INFO: more one files
			break;
		fi


		FILENAME="$(ls -1)";


# check file type
		check_file_type "${FILENAME}";
		if [ "${?}" == "0" ];
		then
#			echo "INFO: file not support type, pack";
			FLAG_OK=1; # file not support type, pack
			break;
		fi


# set correct suffix name
# example may be file is 'GZIP' and have suffix name is NOT '.gz'
		mv "${FILENAME}" "${FILENAME}.${EXT}";
		FILENAME_OLD="${FILENAME}";
		FILENAME="${FILENAME}.${EXT}";


# unpack TAR
		if [ "${FLAG_TAR}" == "1" ];
		then
#			echo "INFO: do TAR";

			tar -xf "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack GZIP
		if [ "${FLAG_GZIP}" == "1" ];
		then
#			echo "INFO: do GZIP";

			if [ "${FLAG_FOUND_GZIP}" == "0" ];
			then
				echo "ERROR: gzip not found";
				break;
			fi

			gzip -df "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack BZIP2
		if [ "${FLAG_BZIP2}" == "1" ];
		then
#			echo "INFO: do BZIP2";

			if [ "${FLAG_FOUND_BZIP2}" == "0" ];
			then
				echo "ERROR: bzip2 not found";
				break;
			fi

			bzip2 -df "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack XZ
		if [ "${FLAG_XZ}" == "1" ];
		then
#			echo "INFO: do XZ";

			if [ "${FLAG_FOUND_XZ}" == "0" ];
			then
				echo "ERROR: xz not found";
				break;
			fi

			xz -df "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack RAR
		if [ "${FLAG_RAR}" == "1" ];
		then
#			echo "INFO: do RAR";

			if [ "$(which unrar)" == "" ];
			then
				echo "ERROR: unrar not found";
				break;
			fi

			unrar x "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack ZIP
		if [ "${FLAG_ZIP}" == "1" ];
		then
#			echo "INFO: do ZIP";

			if [ "$(which unzip)" == "" ];
			then
				echo "ERROR: unzip not found";
				break;
			fi

			unzip "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


# unpack ARJ
		if [ "${FLAG_ARJ}" == "1" ];
		then
#			echo "INFO: do ARJ";

			if [ "$(which arj)" == "" ];
			then
				echo "ERROR: arj not found";
				break;
			fi

			arj x "${FILENAME}" &> /dev/null;
			if [ "${?}" != "0" ];
			then
#				echo "ERROR: \"${FILENAME_OLD}\" unpack error";
				echo "ERROR: unpack error";
				break;
			fi

			rm -rf "${FILENAME}" &> /dev/null;
		fi


	done
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# repack file
function repack()
{
	if [ "${1}" == "" ];
	then
		echo "ERROR: file not found";
		return 1;
	fi

	if [ -d "${1}" ];
	then
		echo "ERROR: is dir";
		return 1;
	fi

	if [ "${1}" == "" ] || [ ! -f "${1}" ];
	then
		echo "ERROR: file not found";
		return 1;
	fi


	SIZE_OLD=$(stat --printf '%s' "${1}");


	SOURCE_FILENAME=$(basename "${1}");
#	echo "SOURCE_FILENAME: ${SOURCE_FILENAME}";


	SOURCE_DIRNAME=$(dirname "${1}");
#	echo "SOURCE_DIRNAME: ${SOURCE_DIRNAME}";


# check file type
	check_file_type "${1}";
	if [ "${?}" == "0" ];
	then
		echo "ERROR: file not support type";
		return 1;
	fi


# save work dir
	DIR_CUR="${PWD}";


# go to source dir
	cd "${SOURCE_DIRNAME}";


# create temp dir
#	TMP1="$(mktemp -d)";
	TMP1="$(mktemp -d --tmpdir="./")";
#echo "TMP1: \"${TMP1}\"";

	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# go to temp dir
	cd "${TMP1}";


# link to source file in tmp dir
	ln -sf "../${SOURCE_FILENAME}";


# unpack
	unpack;
	if [ "${FLAG_OK}" == "0" ];
	then
		cd "${DIR_CUR}";
		rm -rf "${TMP1}";
		return 1;
	fi


# go to work dir
	cd "${DIR_CUR}";

# go to source dir
	cd "${SOURCE_DIRNAME}";


# make TAR

#	TMP2="$(mktemp)";
#echo "TMP2: \"${TMP2}\"";
	TMP2="$(mktemp --tmpdir="./")";
#echo "TMP2: \"${TMP2}\"";

	TMP2="$(basename "${TMP2}")";
#echo "TMP2: \"${TMP2}\"";


	TMP3="$(mktemp --tmpdir="./")";
#echo "TMP3: \"${TMP3}\"";

	TMP3="$(basename "${TMP3}")";
#echo "TMP3: \"${TMP3}\"";


# go to temp dir
	cd "${TMP1}";

# make file list
	ls -1 > "../${TMP3}";

# add files to TAR
	while read -r i;
	do
		ionice -c 3 nice -n 20 tar -rf "../${TMP2}" "${i}";
		if [ "${?}" != "0" ];
		then
			cd "${DIR_CUR}";
			cd "${SOURCE_DIRNAME}";
			rm -rf "${TMP1}";
			rm -rf "${TMP2}";
			rm -rf "${TMP3}";
			cd "${DIR_CUR}";
			return 1;
		fi
	done < "../${TMP3}";


	cd "${DIR_CUR}";
	cd "${SOURCE_DIRNAME}";
	rm -rf "${TMP1}";
	rm -rf "${TMP3}";


# compress TAR
	FLAG_PACK=0;
	TMP4="$(mktemp --tmpdir="./")";
#echo "TMP4: \"${TMP4}\"";


	if [ "${FLAG_PACK}" == "0" ] && [ "${FLAG_FOUND_XZ}" != "0" ];
	then
		if [ "${XZ_OPT}" == "" ];
		then
			export XZ_OPT='-9 --extreme';
		fi

		ionice -c 3 nice -n 20 xz -zc "${TMP2}" > "${TMP4}";
		if [ "${?}" != "0" ];
		then
			rm -rf "${TMP2}";
			rm -rf "${TMP4}";
			return 1;
		fi

		EXT="xz";
		FLAG_PACK=1;
	fi


	if [ "${FLAG_PACK}" == "0" ] && [ "${FLAG_FOUND_BZIP2}" != "0" ];
	then
		if [ "${BZIP2}" == "" ];
		then
			export BZIP2='-9';
		fi

		ionice -c 3 nice -n 20 bzip2 -zc "${TMP2}" > "${TMP4}";
		if [ "${?}" != "0" ];
		then
			rm -rf "${TMP2}";
			rm -rf "${TMP4}";
			return 1;
		fi

		EXT="bz2";
		FLAG_PACK=1;
	fi


	if [ "${FLAG_PACK}" == "0" ] && [ "${FLAG_FOUND_GZIP}" != "0" ];
	then
		if [ "${GZIP}" == "" ];
		then
			export GZIP='-9';
		fi

		ionice -c 3 nice -n 20 gzip -c "${TMP2}" > "${TMP4}";
		if [ "${?}" != "0" ];
		then
			rm -rf "${TMP2}";
			rm -rf "${TMP4}";
			return 1;
		fi

		EXT="gz";
		FLAG_PACK=1;
	fi


# kill TAR
	rm -rf "${TMP2}";


# check pack tar
	if [ "${FLAG_PACK}" == "0" ];
	then
		cd "${DIR_CUR}";
		echo "ERROR: install xz or bzip2 or gzip";
		return 1;
	fi


# check pack size
	SIZE_NEW=$(stat --printf '%s' "${TMP4}");
	if [ ${SIZE_NEW} -ge ${SIZE_OLD} ] && [ "${FLAG_REPACK_FORCE}" != "1" ]; # if SIZE_NEW >= SIZE_OLD
	then
		rm -rf "${TMP4}";
		cd "${DIR_CUR}";
		echo "-0 B";
		return 0;
	fi


	strip_filename "${SOURCE_FILENAME}";

	TARGET_FILENAME="${FILENAME}.tar.${EXT}";
#	echo "${SOURCE_FILENAME} -> ${TARGET_FILENAME}";

	if [ -e "${TARGET_FILENAME}" ] && [ "${TARGET_FILENAME}" != "${SOURCE_FILENAME}" ];
	then
		rm -rf "${TMP4}";
		cd "${DIR_CUR}";
		echo "ERROR: file already exist";
		return 1;
	fi


#	echo "${SIZE_OLD} -> ${SIZE_NEW}";

	SIZE="${SIZE_NEW}";
	(( SIZE-=SIZE_OLD ));

	HUMAN_SIZE="$(human_size ${SIZE})";

	if [ "${HUMAN_SIZE:0:1}" == "-" ];
	then
		echo "${HUMAN_SIZE}";
	else
		echo "+${HUMAN_SIZE}";
	fi

	mv "${TMP4}" "${TARGET_FILENAME}";

	if [ "${TARGET_FILENAME}" != "${SOURCE_FILENAME}" ];
	then
		rm -rf "${SOURCE_FILENAME}";
	fi

	cd "${DIR_CUR}";

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	FILE_COUNT="${#}";
	if [ "${FILE_COUNT}" == "0" ];
	then
		echo "example: ${0} FILE...";
		return 1;
	fi


# check minimal depends tools
	check_prog "basename dirname echo file ionice ln ls mktemp mv nice rm sed stat tar wc which";
	if [ "${?}" == "0" ];
	then
		return 1;
	fi


# check compressor
	check_compressor;
	if [ "${FLAG_FOUND_GZIP}" == "0" ] && [ "${FLAG_FOUND_BZIP2}" == "0" ] && [ "${FLAG_FOUND_XZ}" == "0" ];
	then
		echo "ERROR: install xz or bzip2 or gzip";
		return 1;
	fi


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
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
