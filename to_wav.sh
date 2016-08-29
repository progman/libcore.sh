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
	if [ "${1}" == "" ];
	then
		echo "example: ${0} FILE";
		return 1;
	fi


# check depends tools
	check_prog "echo mplayer";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	local SOURCE="${1}";
	local WAV="${SOURCE}.wav";


# convert
	mplayer -vo null -ao pcm:file="${WAV}.tmp" "${SOURCE}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: unknown error";
		return 1;
	fi


# rename
	mv -- "${WAV}.tmp" "${WAV}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: unknown error";
		return 1;
	fi


	return "${?}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
