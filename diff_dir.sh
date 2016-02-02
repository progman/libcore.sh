#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
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
# test1
function test1()
{
	local D1;
	D1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi

	local D2;
	D2=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		return 1;
	fi

	local cur_pwd=${PWD};

	cd "${cur_pwd}";
	cd "${1}"
	find ./ -type f | sort > "${D1}";

	cd "${cur_pwd}";
	cd "${2}"
	find ./ -type f | sort > "${D2}";

	cd "${cur_pwd}";


	local D1_HASH=$(sha1sum "${D1}" | { read a b; echo ${a}; });
	local D2_HASH=$(sha1sum "${D2}" | { read a b; echo ${a}; });

	if [ "${D1_HASH}" == "${D2_HASH}" ];
	then
		echo "file list == file list";
	else
		echo "file list != file list";

		echo;
		diff -u --minimal ${D1} ${D2} | grep -v '^---' | grep -v '^+++' | grep -v '^@@' | grep '^-\|^+';
	fi

	rm -rf ${D1} &> /dev/null;
	rm -rf ${D2} &> /dev/null;

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# test2
function test2()
{
	local D1;
	D1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi

	local D2;
	D2=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		return 1;
	fi

	local cur_pwd=${PWD};

	cd "${cur_pwd}";
	cd "${1}"
	find ./ | sort > "${D1}";

	cd "${cur_pwd}";
	cd "${2}"
	find ./ | sort > "${D2}";

	cd "${cur_pwd}";


	local D1_HASH=$(sha1sum "${D1}" | { read a b; echo ${a}; });
	local D2_HASH=$(sha1sum "${D2}" | { read a b; echo ${a}; });

	if [ "${D1_HASH}" == "${D2_HASH}" ];
	then
		echo "dir  list == dir  list";
	else
		echo "dir  list != dir  list";

		echo;
		diff -u --minimal ${D1} ${D2} | grep -v '^---' | grep -v '^+++' | grep -v '^@@' | grep '^-\|^+';
	fi

	rm -rf ${D1} &> /dev/null;
	rm -rf ${D2} &> /dev/null;

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#test3
function test3()
{
	local D1;
	D1=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi

	local D2;
	D2=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		return 1;
	fi

	local D3;
	D3=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		rm -rf ${D2} &> /dev/null;
		return 1;
	fi

	local D4;
	D4=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		rm -rf ${D2} &> /dev/null;
		rm -rf ${D3} &> /dev/null;
		return 1;
	fi

	local D5;
	D5=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		rm -rf ${D2} &> /dev/null;
		rm -rf ${D3} &> /dev/null;
		rm -rf ${D4} &> /dev/null;
		return 1;
	fi

	local D6;
	D6=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		rm -rf ${D2} &> /dev/null;
		rm -rf ${D3} &> /dev/null;
		rm -rf ${D4} &> /dev/null;
		rm -rf ${D5} &> /dev/null;
		return 1;
	fi

	local D7;
	D7=$(mktemp 2> /dev/null);
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf ${D1} &> /dev/null;
		rm -rf ${D2} &> /dev/null;
		rm -rf ${D3} &> /dev/null;
		rm -rf ${D4} &> /dev/null;
		rm -rf ${D5} &> /dev/null;
		rm -rf ${D6} &> /dev/null;
		return 1;
	fi

	local cur_pwd=${PWD};


	cd "${cur_pwd}";
	cd "${1}"
	find ./ -type f > "${D1}";


	local FILENAME;


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

	diff -u --minimal ${D3} ${D6} > "${D7}";
	local LOG_SIZE=$(wc -c "${D7}" | { read a b; echo ${a}; });

	if [ "${LOG_SIZE}" == "0" ];
	then
		echo "file body == file body";
	else
		echo "file body != file body";

		echo;
		cat "${D7}" | grep -v '^---' | grep -v '^+++' | grep -v '^@@' | grep '^-\|^+';
	fi


	rm -rf ${D1} &> /dev/null;
	rm -rf ${D2} &> /dev/null;
	rm -rf ${D3} &> /dev/null;
	rm -rf ${D4} &> /dev/null;
	rm -rf ${D5} &> /dev/null;
	rm -rf ${D6} &> /dev/null;
	rm -rf ${D7} &> /dev/null;

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
	check_prog "diff echo find md5sum mktemp rm sha1sum sort stat wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	test1 "${1}" "${2}";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	test2 "${1}" "${2}";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	test3 "${1}" "${2}";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
