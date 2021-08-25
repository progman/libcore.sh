#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.6
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# convert wav to mp3
function convert_wav2mp3()
{
	local SOURCE="${1}";
	local TARGET="${2}";


# convert
	lame --quiet -h -q 0 -v -V 0 -B 320 "${SOURCE}" "${TARGET}.tmp" < /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${TARGET}.tmp" &> /dev/null < /dev/null;
		echo "ERROR[lame()]: unknown error";
		return 1;
	fi


# rename
	mv -- "${TARGET}.tmp" "${TARGET}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${TARGET}.tmp" &> /dev/null < /dev/null;
		echo "ERROR[rename()]: unknown error";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# convert something to wav
function convert_something2wav()
{
	local SOURCE="${1}";
	local TARGET="${2}";


# convert
	mplayer --vo=null --ao=pcm --ao-pcm-file="${TARGET}.tmp" "${SOURCE}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${TARGET}.tmp" &> /dev/null < /dev/null;
		echo "ERROR: unknown error";
		return 1;
	fi


# rename
	mv -- "${TARGET}.tmp" "${TARGET}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${TARGET}.tmp" &> /dev/null < /dev/null;
		echo "ERROR[rename()]: unknown error";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function get_target_name()
{
	echo "${1}.mp3";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# convert something to mp3
function convert()
{
	local SOURCE="${1}";
	local TARGET;
	local MIME="$(file -b -L --mime-type -- "${SOURCE}")";

	local ALBUM_TITLE;
	local CUR_TRACK;
	local TRACK_COUNT;
	local TRACK_TITLE;
	local TRACK_PERFORMER;

	local COMMENT;
	local DATE;
	local GENRE;

	local LOCAL_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi


	local TMP;
	TMP="$(mktemp --tmpdir="${LOCAL_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make tmp file";
		return 1;
	fi


	TARGET=$(get_target_name "${SOURCE}");
#	echo ${TARGET}


	if [ "${MIME}" == "audio/x-wav" ];
	then
#		TARGET=$(echo "${SOURCE}" | sed -e 's/\.wav$/\.mp3/gi');

		convert_wav2mp3 "${SOURCE}" "${TARGET}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi
		rm -rf -- "${TMP}" &> /dev/null < /dev/null;


		echo "ok";
		return 0;
	fi


	if [ "${MIME}" == "audio/x-flac" ];
	then
#		TARGET=$(echo "${SOURCE}" | sed -e 's/\.flac$/\.mp3/gi');

		ALBUM_TITLE=$(metaflac --show-tag ALBUM "${SOURCE}" | sed -e 's/.*=//g');
		CUR_TRACK=$(metaflac --show-tag TRACKNUMBER "${SOURCE}" | sed -e 's/.*=//g');
		TRACK_COUNT=$(metaflac --show-tag TOTALTRACKS "${SOURCE}" | sed -e 's/.*=//g');
		TRACK_TITLE=$(metaflac --show-tag TITLE "${SOURCE}" | sed -e 's/.*=//g');
		TRACK_PERFORMER=$(metaflac --show-tag ARTIST "${SOURCE}" | sed -e 's/.*=//g');

		COMMENT=$(metaflac --show-tag COMMENT "${SOURCE}" | sed -e 's/.*=//g');
		DATE=$(metaflac --show-tag DATE "${SOURCE}" | sed -e 's/.*=//g');
		GENRE=$(metaflac --show-tag GENRE "${SOURCE}" | sed -e 's/.*=//g');


		convert_something2wav "${SOURCE}" "${TMP}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		convert_wav2mp3 "${TMP}" "${TARGET}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		id3v2 -2 --album "${ALBUM_TITLE}" "${TARGET}"; # Set the album title information
		id3v2 -2 --track "${CUR_TRACK}/${TRACK_COUNT}" "${TARGET}"; # Set the track number/(optional) total tracks
		id3v2 -2 --song "${TRACK_TITLE}" "${TARGET}"; # Set the song title information
		id3v2 -2 --artist "${TRACK_PERFORMER}" "${TARGET}"; # Set the artist information

		id3v2 -2 --comment "${COMMENT}" "${TARGET}"; # Set comment

		rm -rf -- "${TMP}" &> /dev/null < /dev/null;


		echo "ok";
		return 0;
	fi


	if [ "${MIME}" == "audio/x-ape" ] || [ "${MIME}" == "audio/mpeg" ];
	then
#		TARGET=$(echo "${SOURCE}" | sed -e 's/\.ape$/\.mp3/gi');

		ALBUM_TITLE=$(mplayer --vo=null --ao=null -identify -frames 0 "${SOURCE}" 2>&1 | grep '^ Album: ' | sed -e 's/^ Album: //g');
		CUR_TRACK=$(mplayer --vo=null --ao=null -identify -frames 0 "${SOURCE}" 2>&1 | grep '^ Track: ' | sed -e 's/^ Track: //g');
		TRACK_COUNT=$(mplayer --vo=null --ao=null -identify -frames 0 "${SOURCE}" 2>&1 | grep '^ Totaltracks: ' | sed -e 's/^ Totaltracks: //g');
		TRACK_TITLE=$(mplayer --vo=null --ao=null -identify -frames 0 "${SOURCE}" 2>&1 | grep '^ Title: ' | sed -e 's/^ Title: //g');
		TRACK_PERFORMER=$(mplayer --vo=null --ao=null -identify -frames 0 "${SOURCE}" 2>&1 | grep '^ Artist: ' | sed -e 's/^ Artist: //g');


		convert_something2wav "${SOURCE}" "${TMP}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		convert_wav2mp3 "${TMP}" "${TARGET}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		id3v2 -2 --album "${ALBUM_TITLE}" "${TARGET}"; # Set the album title information
		id3v2 -2 --track "${CUR_TRACK}/${TRACK_COUNT}" "${TARGET}"; # Set the track number/(optional) total tracks
		id3v2 -2 --song "${TRACK_TITLE}" "${TARGET}"; # Set the song title information
		id3v2 -2 --artist "${TRACK_PERFORMER}" "${TARGET}"; # Set the artist information
#		id3v2 -2 --comment "${COMMENT}" "${TARGET}"; # Set comment

		rm -rf -- "${TMP}" &> /dev/null < /dev/null;


		echo "ok";
		return 0;
	fi


	if [ "${MIME}" == "audio/ogg" ];
	then
#		TARGET=$(echo "${SOURCE}" | sed -e 's/\.ogg$/\.mp3/gi');

		ALBUM_TITLE=$(ogginfo "${SOURCE}" 2>&1 | grep -P '^\tALBUM=' | sed -e 's/.*ALBUM=//g');
		CUR_TRACK=$(ogginfo "${SOURCE}" 2>&1 | grep -P '^\tTRACKNUMBER=' | sed -e 's/.*TRACKNUMBER=//g' | sed -e 's/\/.*//g');
		TRACK_COUNT=$(ogginfo "${SOURCE}" 2>&1 | grep -P '^\tTRACKNUMBER=' | sed -e 's/.*TRACKNUMBER=//g' | sed -e 's/.*\///g');
		TRACK_TITLE=$(ogginfo "${SOURCE}" 2>&1 | grep -P '^\tTITLE=' | sed -e 's/.*TITLE=//g');
		TRACK_PERFORMER=$(ogginfo "${SOURCE}" 2>&1 | grep -P '^\tARTIST=' | sed -e 's/.*ARTIST=//g');


#echo "ALBUM_TITLE: [${ALBUM_TITLE}]";
#echo "CUR_TRACK: [${CUR_TRACK}]";
#echo "TRACK_COUNT: [${TRACK_COUNT}]";
#echo "TRACK_TITLE: [${TRACK_TITLE}]";
#echo "TRACK_PERFORMER: [${TRACK_PERFORMER}]";


		convert_something2wav "${SOURCE}" "${TMP}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		convert_wav2mp3 "${TMP}" "${TARGET}";
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${TMP}" &> /dev/null < /dev/null;
			return 1;
		fi


		id3v2 -2 --album "${ALBUM_TITLE}" "${TARGET}"; # Set the album title information
		id3v2 -2 --track "${CUR_TRACK}/${TRACK_COUNT}" "${TARGET}"; # Set the track number/(optional) total tracks
		id3v2 -2 --song "${TRACK_TITLE}" "${TARGET}"; # Set the song title information
		id3v2 -2 --artist "${TRACK_PERFORMER}" "${TARGET}"; # Set the artist information
#		id3v2 -2 --comment "${COMMENT}" "${TARGET}"; # Set comment

		rm -rf -- "${TMP}" &> /dev/null < /dev/null;


		echo "ok";
		return 0;
	fi


	echo "unknown type";
	rm -rf -- "${TMP}" &> /dev/null < /dev/null;
	return 0;
}
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
	check_prog "echo cat lame mktemp";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ls -1 *.wav | ${0}";
		return 1;
	fi


	local TMP;
	TMP=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi


	while read -r FILE;
	do
		echo "${FILE}" >> "${TMP}";
	done


	local COUNT_CUR=1;
	local COUNT_ALL;
	COUNT_ALL=$(wc -l "${TMP}" | { read a b; echo ${a}; });


# convert
	while read -r FILE;
	do
		if [ -e "${FILE}" ];
		then
			echo -n "[${COUNT_CUR}/${COUNT_ALL}] ${FILE} ... ";

			convert "${FILE}";
			if [ "${?}" != "0" ];
			then
				return 1;
			fi

#			rm -- -rf "${FILE}" &> /dev/null;
		fi

		(( COUNT_CUR++ ));

	done < "${TMP}";


	rm -- -rf "${TMP}" &> /dev/null;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
