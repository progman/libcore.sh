#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.4
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
		echo "example: ${0} [BRANCH] [packet_name:amd64|packet_name:i386]";
		return 1;
	fi


# check depends tools
	check_prog "cat dpkg echo grep head rm sed wget";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ "${UID}" != "0" ];
	then
		echo "ERROR: you not root";
		return 1;
	fi


	if [ ! -f /etc/debian_version ];
	then
		echo "ERROR: is not Debian GNU/Linux";
		return 1;
	fi


	local BRANCH;
	BRANCH="$(sed -e 's/.*\///g' /etc/debian_version)";
	if [ "${BRANCH}" != "wheezy" ] && [ "${BRANCH}" != "jessie" ] && [ "${BRANCH}" != "sid" ];
	then
		BRANCH="sid";
	fi


	local ARG=${1};
	if [ "${2}" != "" ];
	then
		BRANCH=${1};
		ARG=${2};
	fi


	local FLAG_OK=0;
	local NAME="";
	local ARCH="";
	local URL="";

	if [ "${FLAG_OK}" == "0" ];
	then
		ARCH="i386";
		if [ ${#ARG} -lt ${#ARCH} ]; # strlen(1) < strlen(ARCH)
		then
			echo "ERROR: broken packet_name";
			return 1;
		fi

		local OFFSET=${#ARG};
		(( OFFSET-=${#ARCH} ));

		if [ "${ARG:${OFFSET}}" == "${ARCH}" ];
		then
			FLAG_OK=1;
			(( OFFSET-- ));
			NAME="${ARG:0:${OFFSET}}";
		fi
	fi


	if [ "${FLAG_OK}" == "0" ];
	then
		ARCH="amd64";
		if [ ${#ARG} -lt ${#ARCH} ]; # strlen(1) < strlen(ARCH)
		then
			echo "ERROR: broken packet_name";
			return 1;
		fi

		local OFFSET=${#ARG};
		(( OFFSET-=${#ARCH} ));

		if [ "${ARG:${OFFSET}}" == "${ARCH}" ];
		then
			FLAG_OK=1;
			(( OFFSET-- ));
			NAME="${ARG:0:${OFFSET}}";
		fi
	fi


	if [ "${FLAG_OK}" == "0" ];
	then
		echo "ERROR: broken packet_name";
		return 1;
	fi


	echo "BRANCH : \"${BRANCH}\"";
	echo "ARCH   : \"${ARCH}\"";
	echo "NAME   : \"${NAME}\"";


	TMP="$(mktemp 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: mktemp";
		return 1;
	fi


	URL="https://packages.debian.org/${BRANCH}/${ARCH}/${NAME}/download";
	wget -O "${TMP}" -q -c "${URL}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: wget";
		rm -rf "${TMP}" &> /dev/null;
		return 1;
	fi


	FILE="$(cat "${TMP}" | grep href | grep '\.deb"' | head -n 1 | sed -e 's/">.*//g' | sed -e 's/.*"//g')";
	if [ "${FILE}" == "" ];
	then
		echo "ERROR: deb not found in \"${URL}\"";
		rm -rf "${TMP}" &> /dev/null;
		return 1;
	fi


	rm -rf "${TMP}" &> /dev/null;
	echo "cd /var/cache/apt/archives/;";
	cd /var/cache/apt/archives/;
	echo "wget -c \"${FILE}\";";
	wget -q -c "${FILE}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: wget";
		return 1;
	fi

	FULLNAME=$(echo "${FILE}" | sed -e 's/.*\///g');

	echo "dpkg -i --force-all /var/cache/apt/archives/${FULLNAME} && apt-get install -f";
	echo;


	dpkg -i --force-all "${FULLNAME}" && apt-get install -f;


	return "${?}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
