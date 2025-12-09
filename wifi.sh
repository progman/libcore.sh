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
		if [ "$(command -v ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function connect()
{
#ip link set wlo1 up
	nmcli device wifi list --rescan yes | head -n 30;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: did not scan";
		return 1;
	fi


	if [ "${WIFI_SSID}" == "" ];
	then
		echo "ERROR: WIFI_SSID is empty";
		return 1;
	fi
	echo "use \"${WIFI_SSID}\"";


	if [ "${WIFI_PASSWORD}" == "" ];
	then
		echo "ERROR: password is empty";
		return 1;
	fi


	echo "nmcli connection delete \"${WIFI_SSID}\"";
	nmcli connection delete "${WIFI_SSID}" &> /dev/null < /dev/null;
#	if [ "${?}" != "0" ];
#	then
#		echo "ERROR: WIFI_SSID did not delete";
#		return 1;
#	fi


	echo "nmcli device wifi connect \"${WIFI_SSID}\" password \"*\"";
	nmcli device wifi connect "${WIFI_SSID}" password "${WIFI_PASSWORD}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: WIFI_SSID did not connect";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function fix_resolv()
{
	touch /etc/resolv.conf &> /dev/null < /dev/null;


	if [ "$(cat /etc/resolv.conf | grep '8.8.8.8' | wc -l  | { read a b; echo ${a}; })" != "0" ];
	then
		echo "/etc/resolv.conf has 8.8.8.8";
		return 0;
	fi
	echo "/etc/resolv.conf will have 8.8.8.8";


	local TMP="/etc/resolv.conf.wifi_tmp";


	rm -rf -- "${TMP}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "can't rm tmp file";
		return 1;
	fi


	echo "nameserver 8.8.8.8" >> "${TMP}";
	echo "nameserver 1.1.1.1" >> "${TMP}";
	cat /etc/resolv.conf >> "${TMP}";
	sync;


	mv "${TMP}" /etc/resolv.conf &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "can't mv tmp file";
		return 1;
	fi
	sync;


	chown root:root /etc/resolv.conf &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "can't chown tmp file";
		return 1;
	fi


	chmod 0644 /etc/resolv.conf &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "can't chmod tmp file";
		return 1;
	fi


	sync;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function connect_test()
{
	host ya.ru;


	ping -c 3 ya.ru


	echo "done";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "nmcli cat grep wc echo touch read rm sync mv chown chmod host ping";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	connect;


	fix_resolv;


	connect_test;


	return "${?}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
