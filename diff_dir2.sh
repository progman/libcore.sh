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
# general function
function main()
{
	if [ ! -d "${1}" ] || [ ! -d "${2}" ];
	then
		echo "example: ${0} DIR1 DIR2";
		return 0;
	fi

# check depends tools
	check_prog "echo md5sum stat sort find diff rm";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	D1=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	D2=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	D3=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	D4=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	D5=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	D6=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	cur_pwd=${PWD};


	cd "${cur_pwd}";
	cd "${1}"
	find ./ -type f > "${D1}";


	while read -r FILENAME;
	do

		A="$(md5sum "${FILENAME}")";
		B="$(stat --printf '%s' "${FILENAME}")";
		C="${B} ${A}";
		echo "${C}" >> "${D2}";

	done < "${D1}";
	sort "${D2}" > "${D3}";



	cd "${cur_pwd}";
	cd "${2}"
	find ./ -type f > "${D4}";


	while read -r FILENAME;
	do

		A="$(md5sum "${FILENAME}")";
		B="$(stat --printf '%s' "${FILENAME}")";
		C="${B} ${A}";
		echo "${C}" >> "${D5}";

	done < "${D4}";
	sort "${D5}" > "${D6}";


	cd "${cur_pwd}";

	diff -u --minimal ${D3} ${D6} > log;

	rm -rf ${D1} &> /dev/null;
	rm -rf ${D2} &> /dev/null;
	rm -rf ${D3} &> /dev/null;
	rm -rf ${D4} &> /dev/null;
	rm -rf ${D5} &> /dev/null;
	rm -rf ${D6} &> /dev/null;

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
