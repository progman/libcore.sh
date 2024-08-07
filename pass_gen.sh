#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.3
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
# check depends tools
	check_prog "echo head hexdump tr";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} [ --fast | -6 ]";
		return 0;
	fi


	DEVICE='/dev/random';
	if [ "${1}" == "--fast" ];
	then
		DEVICE='/dev/urandom';
	fi


	COUNT=64; # 64 bytes = 512 bits = 128 chars
	if [ "${1}" == "-6" ] || [ "${1}" == "--6" ];
	then
		COUNT=3; # 3 bytes = 24 bits = 6 chars
	fi
	if [ "${1}" == "-8" ] || [ "${1}" == "--8" ];
	then
		COUNT=4; # 4 bytes = 32 bits = 8 chars
	fi


	head -c ${COUNT} ${DEVICE} | hexdump -v -e '/1 "%02X"' | tr [:upper:] [:lower:];
	echo;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
