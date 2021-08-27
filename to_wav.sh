#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.5
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
# general function
function main()
{
	if [ "${1}" == "" ];
	then
		echo "example: ${0} FILE";
		return 1;
	fi


# check depends tools
	check_prog "echo";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi

	if [ "$(command -v ffmpeg)" == "" ] && [ "$(command -v mpv)" == "" ] && [ "$(command -v mplayer)" == "" ];
	then
		echo "FATAL: you must install \"mplayer\" or \"mpv\"...";
		return 1;
	fi


	local SOURCE="${1}";
	local WAV="${SOURCE}.wav";


# convert
	while true;
	do
		if [ "$(command -v ffmpeg)" != "" ];
		then
			ffmpeg -i "${SOURCE}" "/tmp/to_wav.wav" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: unknown error, 1";
				return 1;
			fi

			mv -- "/tmp/to_wav.wav" "${WAV}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR[rename()]: unknown error, 2";
				return 1;
			fi

			break;
		fi


		if [ "$(command -v mpv)" != "" ];
		then
			mpv --vo=null --ao=pcm --ao-pcm-file="${WAV}.tmp" "${SOURCE}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: unknown error, 3";
				return 1;
			fi

			mv -- "${WAV}.tmp" "${WAV}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR[rename()]: unknown error, 4";
				return 1;
			fi

			break;
		fi


		if [ "$(command -v mplayer)" != "" ];
		then
			mplayer --vo=null --ao=pcm --ao-pcm-file="${WAV}.tmp" "${SOURCE}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: unknown error, 5";
				return 1;
			fi

			mv -- "${WAV}.tmp" "${WAV}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR[rename()]: unknown error, 6";
				return 1;
			fi

			break;
		fi


		break;
	done


	return "${?}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
