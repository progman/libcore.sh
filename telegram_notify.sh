#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#1) add @BotFather for friends
#
#2) send message for @BotFather: /newbot
#
#3) send message for @BotFather like: super puper bot
#
#4) send message for @BotFather like: super_puper_bot
#
#5) @BotFather will give you BOT_TOKEN, save it
#
#6) make your telegram group/channel
#
#7) add bot in your group/channel
#
#8) grant admin role for bot in your group/channel
#
#9) send some message in your group/channel
#
#10) use browser for open url: https://api.telegram.org/botBOT_TOKEN/getUpdates?offset=-10 (replase BOT_TOKEN to your BOT_TOKEN)
#    curl -s https://api.telegram.org/botBOT_TOKEN/getUpdates?offset=-10 | jq
#
#11) read answer like:
#
#{
#...
#    "result" :
#    [
#        {
#...
#            "my_chat_member" :
#            {
#                "chat" :
#                {
#                    "id" : CHANNEL_ID,
#...
#                },
#...
#            },
#        },
#...
#    ]
#}
#
#12) save CHANNEL_ID
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
	local STATUS;
	local TELEGRAM_BOT_TOKEN;
	local TELEGRAM_CHAT_ID;
	local MSG;
	local URL;


	TELEGRAM_BOT_TOKEN="${1}";
	TELEGRAM_CHAT_ID="${2}";
	MSG="${3}";


# check depends tools
	check_prog "curl";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# notify
	URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage";
#	curl --socks5-hostname localhost:9050 -s -X POST ${URL} -d chat_id=${TELEGRAM_CHAT_ID} -d parse_mode=markdown -d text="*${MSG}*" &> /dev/null;
	curl -s -X POST ${URL} -d chat_id=${TELEGRAM_CHAT_ID} -d parse_mode=markdown -d text="*${MSG}*" &> /dev/null;
	STATUS="${?}";


	return "${STATUS}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
