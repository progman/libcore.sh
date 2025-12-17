#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.0
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
function notify()
{
# get TELEGRAM_BOT_TOKEN
	local LOCAL_TELEGRAM_BOT_TOKEN;
	LOCAL_TELEGRAM_BOT_TOKEN=$(cat ${CHECK_RAID_CONFIG} | jq -r '.telegram.bot_token');
	export TELEGRAM_BOT_TOKEN="${LOCAL_TELEGRAM_BOT_TOKEN}";
	echo "TELEGRAM_BOT_TOKEN:${TELEGRAM_BOT_TOKEN}";


# get TELEGRAM_CHAT_ID
	local LOCAL_TELEGRAM_CHAT_ID;
	LOCAL_TELEGRAM_CHAT_ID=$(cat ${CHECK_RAID_CONFIG} | jq -r '.telegram.chat_id');
	export TELEGRAM_CHAT_ID="${LOCAL_TELEGRAM_CHAT_ID}";
	echo "TELEGRAM_CHAT_ID:${TELEGRAM_CHAT_ID}";


# get TELEGRAM_NOTIFY
	local LOCAL_TELEGRAM_NOTIFY;
	LOCAL_TELEGRAM_NOTIFY=$(cat ${CHECK_RAID_CONFIG} | jq -r '.telegram.notify');
	export TELEGRAM_NOTIFY="${LOCAL_TELEGRAM_NOTIFY}";
	echo "TELEGRAM_NOTIFY:${TELEGRAM_NOTIFY}";


	"${TELEGRAM_NOTIFY}" "${TELEGRAM_NOTIFY_MSG}" &> /dev/null < /dev/null &
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# help function
function help()
{
	echo "\$ cat /somedir/check_raid.json";
	echo "{";
	echo "  \"telegram\": {";
	echo "        \"bot_token\": \"TELEGRAM_BOT_TOKEN\",";
	echo "        \"chat_id\":   \"TELEGRAM_CHAT_ID\",";
	echo "        \"notify\":    \"TELEGRAM_NOTIFY, for example notify_telegram.sh\",";
	echo "        \"ok_time\":   \"17:00\"";
	echo "  }";
	echo "}";
	echo "\$ export CHECK_RAID_CONFIG='/somedir/check_raid.json';";
	echo "\$ ${1};";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local RAID_STATUS;
	local a;
	local b;


# check depends tools
	check_prog "basename dirname echo file find grep ionice ln ls mktemp mv nice printf readlink rm sed sort stat tar touch uniq wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check args
	if [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		help "${0}";
		return 0;
	fi

	if [ "${CHECK_RAID_CONFIG}" == "" ];
	then
		echo "ERROR: CHECK_RAID_CONFIG is not set";
		return 1;
	fi

	if [ ! -f "${CHECK_RAID_CONFIG}" ];
	then
		echo "ERROR: file from CHECK_RAID_CONFIG is not found";
		return 1;
	fi


# get OK_TIME
	local LOCAL_OK_TIME;
	LOCAL_OK_TIME=$(cat ${CHECK_RAID_CONFIG} | jq -r '.telegram.ok_time');
	export OK_TIME="${LOCAL_OK_TIME}";
	echo "OK_TIME:${OK_TIME}";


# check raid
	RAID_STATUS=$(cat /proc/mdstat | grep '\[U*\]' | wc -l | { read a b; echo ${a}; });
	if [ "${RAID_STATUS}" != "1" ];
	then
		export TELEGRAM_NOTIFY_MSG="RAID IS FAIL!!!";
		notify;
		return 1;
	fi


	TIME=$(date '+%H:%M'); # "hh:mm"
	echo "TIME:${TIME}";


	if [ "${TIME}" == "${OK_TIME}" ];
	then
		export TELEGRAM_NOTIFY_MSG="RAID IS OK";
		notify;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
