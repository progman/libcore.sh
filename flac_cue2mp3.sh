#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.3
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
# general function
function main()
{
	if [ "${1}" == "" ] || [ "${2}" == "" ] || [ ! -e "${1}" ] || [ ! -e "${2}" ];
	then
		echo "flac converter";
		echo "example: ${0} FILE.FLAC FILE.CUE";
		return 1;
	fi


# check depends tools
	check_prog "echo mplayer cuebreakpoints shnsplit cueprint printf lame id3v2 wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# create temp dir and files
	local LOCAL_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi


	local FLAC;
	local CUE;
	local WAV;

	FLAC="${1}";
	CUE="${2}";
	WAV="${FLAC}.wav";


	echo "convert FLAC to WAV...";

	mplayer -vo null -ao pcm:file="${WAV}.tmp" "${FLAC}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[mac()]: unknown error";
		return 1;
	fi

# rename
	mv -- "${WAV}.tmp" "${WAV}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[rename()]: unknown error";
		return 1;
	fi


	echo "split WAV...";


	local TMP;
	TMP="$(mktemp --tmpdir="${LOCAL_TMPDIR}" 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make tmp file";
		return 1;
	fi


	cuebreakpoints "${CUE}" &> "${TMP}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[cuebreakpoints()]: unknown error";
		rm -rf -- "${TMP}";
		return 1;
	fi


	shnsplit -o wav -a 'track' "${WAV}" &> /dev/null < "${TMP}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[shnsplit()]: unknown error";
		rm -rf -- "${TMP}";
		return 1;
	fi


	rm -rf -- "${TMP}";


	local TRACK_COUNT;
#	TRACK_COUNT=$(cat "${CUE}" | grep '^  TRACK' | wc -l);
	TRACK_COUNT=$(cueprint -d '%N\n' "${CUE}");


	local ALBUM_PERFORMER;
	ALBUM_PERFORMER=$(cueprint -d '%P\n' "${CUE}");


	local ALBUM_TITLE;
	ALBUM_TITLE=$(cueprint -d '%T\n' "${CUE}");


#	echo "TRACK_COUNT: ${TRACK_COUNT}";

#	echo "ALBUM_PERFORMER: ${ALBUM_PERFORMER}";
#	echo "ALBUM_TITLE: ${ALBUM_TITLE}";


	echo "convert WAV to MP3...";

	local CUR_TRACK=1;
	while true;
	do
		local TRACK_WAV=$(printf 'track%02u.wav' ${CUR_TRACK});
		local TRACK_MP3=$(printf 'track%02u.mp3' ${CUR_TRACK});


		local TRACK_NUMBER;
		TRACK_NUMBER=$(cueprint --track-number=${CUR_TRACK} -t '%n\n' "${CUE}"); #n           track number

		local TRACK_TITLE;
		TRACK_TITLE=$(cueprint --track-number=${CUR_TRACK} -t '%t\n' "${CUE}"); #t           track title

		local TRACK_PERFORMER;
		TRACK_PERFORMER=$(cueprint --track-number=${CUR_TRACK} -t '%p\n' "${CUE}"); #p           track performer


#		echo "TRACK_NUMBER: ${TRACK_NUMBER}";
#		echo "TRACK_TITLE: ${TRACK_TITLE}";
#		echo "TRACK_PERFORMER: ${TRACK_PERFORMER}";


		echo "[${CUR_TRACK}/${TRACK_COUNT}] ${TRACK_TITLE}";
		lame --quiet -h -q 0 -v -V 0 -B 320 "${TRACK_WAV}" "${TRACK_MP3}.tmp" < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR[lame()]: unknown error";
			return 1;
		fi

# rename
		mv -- "${TRACK_MP3}.tmp" "${TRACK_MP3}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR[rename()]: unknown error";
			return 1;
		fi

		id3v2 -2 --album "${ALBUM_TITLE}" "${TRACK_MP3}"; # Set the album title information
		id3v2 -2 --comment "${ALBUM_PERFORMER}" "${TRACK_MP3}"; # Set the comment information

		id3v2 -2 --track "${CUR_TRACK}/${TRACK_COUNT}" "${TRACK_MP3}"; # Set the track number/(optional) total tracks
		id3v2 -2 --song "${TRACK_TITLE}" "${TRACK_MP3}"; # Set the song title information
		id3v2 -2 --artist "${TRACK_PERFORMER}" "${TRACK_MP3}"; # Set the artist information


		rm -rf -- "${TRACK_WAV}";


		(( CUR_TRACK++ ));

		if [ ${CUR_TRACK} -gt ${TRACK_COUNT} ]; #INTEGER1 is greater than INTEGER2
		then
			break;
		fi
	done;


	rm -rf -- "${WAV}";


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
