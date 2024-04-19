#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function deploy()
{
	export PS1="dirty_hack";
	source /root/.bashrc;

	export DOCKER_DIR="${1}";
	export DOCKER_NOTIFY_MSG="${2}";
	/usr/local/bin/docker_tool.sh deploy &> /dev/null < /dev/null;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
export DOCKER_NOTIFY="/usr/local/bin/notify_telegram.sh";


export TELEGRAM_BOT_TOKEN="TELEGRAM_BOT_TOKEN";
export TELEGRAM_CHAT_ID="TELEGRAM_CHAT_ID";


deploy '/tmp/xxx' "xxx deploy";


sleep 10;


exit 0;
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
