#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function deploy()
{
	export PS1="dirty_hack";
	source /root/.bashrc;

	export DOCKER_DIR="${1}";
	export DOCKER_NOTIFY_MSG="${2}";
	/usr/local/bin/docker_tool.sh deploy &> /dev/null < /dev/null;
#	/usr/local/bin/docker_tool.sh deploy 2>&1 >> /tmp/docker_tool.log < /dev/null;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export DOCKER_NOTIFY="/usr/local/bin/notify_telegram.sh";


export TELEGRAM_BOT_TOKEN="HERE_TELEGRAM_BOT_TOKEN";
export TELEGRAM_CHAT_ID="HERE_TELEGRAM_CHAT_ID";
deploy 'HERE_DIR_OF_DOCKER_COMPOSE_CONFIG' "HERE_MESSAGE_FOR_TELEGRAM";


sleep 10;


exit 0;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
