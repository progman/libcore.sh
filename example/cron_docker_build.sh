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
	/usr/local/bin/git_tool_docker_builder.sh &> /dev/null < /dev/null;
#	/usr/local/bin/git_tool_docker_builder.sh 2>&1 >> /tmp/git_tool_docker_builder.log < /dev/null;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export DOCKER_NOTIFY="/usr/local/bin/notify_telegram.sh";


export TELEGRAM_BOT_TOKEN="HERE_TELEGRAM_BOT_TOKEN";
export TELEGRAM_CHAT_ID="HERE_TELEGRAM_CHAT_ID";
build 'HERE_DIR_OF_GIT_REPO' "HERE_MESSAGE_FOR_TELEGRAM";


sleep 10;


exit 0;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
