#!/bin/bash
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
	if [ "${1}" == "" ];
	then
		echo "example: ${0} [packet_name:amd64|packet_name:i386]";
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


	local FLAG_OK=0;
	local NAME="";
	local ARCH="";

	if [ "${FLAG_OK}" == "0" ];
	then
		ARCH="i386";
		if [ ${#1} -lt ${#ARCH} ]; # strlen(1) < strlen(ARCH)
		then
			echo "ERROR: broken packet_name";
			return 1;
		fi

		local OFFSET=${#1};
		(( OFFSET-=${#ARCH} ));

		if [ "${1:${OFFSET}}" == "${ARCH}" ];
		then
			FLAG_OK=1;
			(( OFFSET-- ));
			NAME="${1:0:${OFFSET}}";
		fi
	fi


	if [ "${FLAG_OK}" == "0" ];
	then
		ARCH="amd64";
		if [ ${#1} -lt ${#ARCH} ]; # strlen(1) < strlen(ARCH)
		then
			echo "ERROR: broken packet_name";
			return 1;
		fi

		local OFFSET=${#1};
		(( OFFSET-=${#ARCH} ));

		if [ "${1:${OFFSET}}" == "${ARCH}" ];
		then
			FLAG_OK=1;
			(( OFFSET-- ));
			NAME="${1:0:${OFFSET}}";
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


	TMP="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: mktemp";
		return 1;
	fi

	wget -O "${TMP}" -q -c "https://packages.debian.org/${BRANCH}/${ARCH}/${NAME}/download" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: wget";
		rm -rf "${TMP}" &> /dev/null;
		return 1;
	fi

	FILE="$(cat "${TMP}" | grep href | grep '\.deb"' | head -n 1 | sed -e 's/">.*//g' | sed -e 's/.*"//g')";

	rm -rf "${TMP}" &> /dev/null;

	cd /var/cache/apt/archives/;
	wget -q -c "${FILE}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: wget";
		return 1;
	fi

	FULLNAME=$(echo "${FILE}" | sed -e 's/.*\///g');

	echo "dpkg -i --force-all /var/cache/apt/archives/${FULLNAME}";
	echo;
	echo;


	dpkg -i --force-all "${FULLNAME}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: dpkg";
		return 1;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
