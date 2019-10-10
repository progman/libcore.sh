#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.1
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "dd echo head modprobe stat tail which";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check permissions
	if [ "${USER}" != "root" ];
	then
		echo "ERROR: you not root";
		return 1;
	fi


	local NVRAM_OLD;
	local NVRAM_NEW;
	local SIZE;


# create tmp files
	NVRAM_OLD="$(mktemp 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	NVRAM_NEW="$(mktemp 2> /dev/null)";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make tmp file";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		return 1;
	fi


# check device
	while true;
	do
		if [ -b /dev/nvram ];
		then
			break;
		fi

		modprobe nvram &> /dev/null < /dev/null;
		if [ "${?}" == "0" ];
		then
			break;
		fi

		echo "ERROR: /dev/nvram not found";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	done


# read from device
	dd if=/dev/nvram of="${NVRAM_OLD}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't read /dev/nvram";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi


# check data
	SIZE=$(stat --printf='%s' "${NVRAM_OLD}");
	if [ "${SIZE}" != "114" ];
	then
		echo "ERROR: invalid size";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi


# patch data
	head -c 109 "${NVRAM_OLD}" 2>/dev/null > "${NVRAM_NEW}" < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make new image";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi

	echo -en "\x00\x00"  2>/dev/null  >> "${NVRAM_NEW}" < /dev/null; # this bad cmos crc, for example http://www.pixelbeat.org/docs/bios/
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make new image";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi

	tail -c 3 "${NVRAM_OLD}" 2>/dev/null >> "${NVRAM_NEW}" < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make new image";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi


	SIZE=$(stat --printf='%s' "${NVRAM_NEW}");
	if [ "${SIZE}" != "114" ];
	then
		echo "ERROR: invalid size";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi


# write to divice
	dd if="${NVRAM_NEW}" of=/dev/nvram &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't write /dev/nvram";
		rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
		rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;
		return 1;
	fi


	rm -rf -- "${NVRAM_OLD}" &> /dev/null < /dev/null;
	rm -rf -- "${NVRAM_NEW}" &> /dev/null < /dev/null;


	echo "ok, must reboot now and enter to bios setup";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
