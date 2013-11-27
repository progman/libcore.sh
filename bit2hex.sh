#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.1
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
# check depends tools
	check_prog "echo sed wc tail head printf";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	local BITSTR="$(echo ${1} | sed -e 's/\ //g')";


	if [ "${BITSTR}" == "" ];
	then
		echo "example: ${0} 01000110";
		return 1;
	fi


	local SIZE=$(echo -n "${BITSTR}" | wc -c);
	local NUM=0;
	local LEN=${SIZE};
	local WEIGHT=1;


	while true;
	do
		if [ "${LEN}" == "0" ];
		then
			break;
		fi


		local BIT=$(echo -n "${BITSTR}" | tail -c 1);
		if [ "${BIT}" != "0" ] && [ "${BIT}" != "1" ];
		then
			echo "ERROR: invalid argument";
			return 1;
		fi


		if [ "${BIT}" == "1" ];
		then
			(( NUM += WEIGHT ));
		fi


		(( LEN-- ));
		BITSTR=$(echo -n "${BITSTR}" | head -c ${LEN});
		(( WEIGHT <<= 1 ));
	done


	if [ ${SIZE} -le 8 ]; # SIZE <= 8
	then
		printf "%02x\n" "${NUM}";
		return 0;
	fi

	if [ ${SIZE} -le 16 ]; # SIZE <= 16
	then
		printf "%04x\n" "${NUM}";
		return 0;
	fi

	if [ ${SIZE} -le 32 ]; # SIZE <= 32
	then
		printf "%08x\n" "${NUM}";
		return 0;
	fi

	if [ ${SIZE} -le 64 ]; # SIZE <= 64
	then
		printf "%016x\n" "${NUM}";
		return 0;
	fi


	echo "ERROR: invalid argument";
	return 1;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
