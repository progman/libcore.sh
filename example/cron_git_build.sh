#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# WARNING! Use special/other git dir for build - if you use one dir then push will be not fetched/detected
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function build()
{
	export PS1="dirty_hack";
	source /root/.bashrc;

	export DOCKER_DIR="${1}";
	export DOCKER_NOTIFY_MSG="${2}";
	/usr/local/bin/git_tool_builder.sh &> /dev/null < /dev/null;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export DOCKER_NOTIFY="/usr/local/bin/notify_telegram.sh";


export TELEGRAM_BOT_TOKEN="TELEGRAM_BOT_TOKEN";
export TELEGRAM_CHAT_ID="TELEGRAM_CHAT_ID";


build '/tmp/xxx' "xxx builded";


sleep 10;


exit 0;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
