#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.4
# Alexey Potehin <gnuplanet@gmail.com>, https://overtask.org/doc/cv
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
function git_fetch()
{
	local FETCH_DIR;
	local FETCH_DIR_HEX;
	local COMMIT_FILE;
	local HASH1;
	local HASH2;
	local HASH3;
	local a;
	local b;


# go to fetch dir
	FETCH_DIR="${1}";
	if [ ! -d "${FETCH_DIR}" ];
	then
		echo "ERROR: fetch dir is not found";
		return 1;
	fi
	cd -- "${FETCH_DIR}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: fetch dir is not change";
		return 1;
	fi
	FETCH_DIR_HEX=$(echo -n "${FETCH_DIR}" | hexdump -ve '/1 "%02x"');


# get temp dir
	local LOCAL_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi
	HASH_COMMIT_FILE="${LOCAL_TMPDIR}/ci_cd_${FETCH_DIR_HEX}"


# touch commit file
	touch "${HASH_COMMIT_FILE}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not touch hash commit file";
		return 1;
	fi


# get stored hash commit
	HASH1=$(cat "${HASH_COMMIT_FILE}");
	echo "HASH1:\"${HASH1}\"";


# status
	echo "git status;";
	git status &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not status repo";
		return 1;
	fi


# get cur hash commit
	HASH2=$(git rev-parse HEAD | shasum -a 1 | { read a b; echo "${a}"; });
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not get commit before pull";
		return 1;
	fi
	echo "HASH2:\"${HASH2}\"";


# compare hashes
	if [ "${HASH2}" != "${HASH1}" ];
	then
#		echo "${HASH2}" > "${HASH_COMMIT_FILE}";
		return 0; # it is new repo and we must build it
	fi


# fetch
	echo "git fetch -a;";
	git fetch -a &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not fetch repo";
		return 1;
	fi


# pull
	echo "git pull;";
	git pull &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not pull repo";
		return 1;
	fi


# pull submodules
	echo "git submodule update --quiet --init --recursive;";
	git submodule update --quiet --init --recursive &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not update submodules";
		return 1;
	fi


# get new commit
	HASH3=$(git rev-parse HEAD | shasum -a 1 | { read a b; echo "${a}"; });
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not get commit after pull";
		return 1;
	fi
	echo "HASH3:\"${HASH3}\"";


# compare before and after fetch commits
	if [ "${HASH3}" == "${HASH2}" ];
	then
		return 2; # nothing to fetch
	fi
#	echo "${HASH3}" > "${HASH_COMMIT_FILE}";


	return 0; # fetched something
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function git_save_hash()
{
	local FETCH_DIR;
	local FETCH_DIR_HEX;
	local COMMIT_FILE;
	local HASH;
	local a;
	local b;


# go to fetch dir
	FETCH_DIR="${1}";
	if [ ! -d "${FETCH_DIR}" ];
	then
		echo "ERROR: fetch dir is not found";
		return 1;
	fi
	cd -- "${FETCH_DIR}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: fetch dir is not change";
		return 1;
	fi
	FETCH_DIR_HEX=$(echo -n "${FETCH_DIR}" | hexdump -ve '/1 "%02x"');


# get temp dir
	local LOCAL_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi
	HASH_COMMIT_FILE="${LOCAL_TMPDIR}/ci_cd_${FETCH_DIR_HEX}"


# status
	echo "git status;";
	git status &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not status repo";
		return 1;
	fi


# get cur hash commit
	HASH=$(git rev-parse HEAD | shasum -a 1 | { read a b; echo "${a}"; });
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not get cur hash commit";
		return 1;
	fi
	echo "HASH:\"${HASH}\"";


# save cur hash commit
	echo "${HASH}" > "${HASH_COMMIT_FILE}.tmp";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not save hash commit, see df -h";
		return 1;
	fi
	mv "${HASH_COMMIT_FILE}.tmp" "${HASH_COMMIT_FILE}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not move hash commit, see df -h";
		return 1;
	fi
	echo "hash saved";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function ci_cd()
{
	local STATUS;


	echo;


# get TELEGRAM_BOT_TOKEN
	local LOCAL_TELEGRAM_BOT_TOKEN;
	LOCAL_TELEGRAM_BOT_TOKEN="$(cat ${CI_CD_CONFIG} | jq -r '.telegram.bot_token')";
	if [ "${TELEGRAM_BOT_TOKEN}" == "" ];
	then
		export TELEGRAM_BOT_TOKEN="${LOCAL_TELEGRAM_BOT_TOKEN}";
	fi
	echo "TELEGRAM_BOT_TOKEN:${TELEGRAM_BOT_TOKEN}";


# get TELEGRAM_CHAT_ID
	local LOCAL_TELEGRAM_CHAT_ID;
	LOCAL_TELEGRAM_CHAT_ID="$(cat ${CI_CD_CONFIG} | jq -r '.telegram.chat_id')";
	if [ "${TELEGRAM_CHAT_ID}" == "" ];
	then
		export TELEGRAM_CHAT_ID="${LOCAL_TELEGRAM_CHAT_ID}";
	fi
	echo "TELEGRAM_CHAT_ID:${TELEGRAM_CHAT_ID}";


# get DOCKER_REGISTRY_HOST
	local LOCAL_DOCKER_REGISTRY_HOST;
	LOCAL_DOCKER_REGISTRY_HOST="$(cat ${CI_CD_CONFIG} | jq -r '.docker_registry.host')";
	if [ "${DOCKER_REGISTRY_HOST}" == "" ];
	then
		export DOCKER_REGISTRY_HOST="${LOCAL_DOCKER_REGISTRY_HOST}";
	fi
	echo "DOCKER_REGISTRY_HOST:${DOCKER_REGISTRY_HOST}";


# get DOCKER_REGISTRY_LOGIN
	local LOCAL_DOCKER_REGISTRY_LOGIN;
	LOCAL_DOCKER_REGISTRY_LOGIN="$(cat ${CI_CD_CONFIG} | jq -r '.docker_registry.login')";
	if [ "${DOCKER_REGISTRY_LOGIN}" == "" ];
	then
		export DOCKER_REGISTRY_LOGIN="${LOCAL_DOCKER_REGISTRY_LOGIN}";
	fi
	echo "DOCKER_REGISTRY_LOGIN:${DOCKER_REGISTRY_LOGIN}";


# get DOCKER_REGISTRY_PASSWORD
	local LOCAL_DOCKER_REGISTRY_PASSWORD;
	LOCAL_DOCKER_REGISTRY_PASSWORD="$(cat ${CI_CD_CONFIG} | jq -r '.docker_registry.password')";
	if [ "${DOCKER_REGISTRY_PASSWORD}" == "" ];
	then
		export DOCKER_REGISTRY_PASSWORD="${LOCAL_DOCKER_REGISTRY_PASSWORD}";
	fi
	echo "DOCKER_REGISTRY_PASSWORD:${DOCKER_REGISTRY_PASSWORD}";


# fetch
	FETCH_LIST_INDEX=0;
	FETCH_LIST_COUNT=$(cat ${CI_CD_CONFIG} | jq '.fetch_list | length');
	while true;
	do
#		echo "=====================================================================================================================";
		TEMPLATE_FETCH=".fetch_list[${FETCH_LIST_INDEX}]";
		FETCH_NAME=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_FETCH}.name");
		FETCH_DIR=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_FETCH}.dir");

#		echo "FETCH_NAME:${FETCH_NAME}";
#		echo "FETCH_DIR:${FETCH_DIR}";
		echo -e "\n[$(date +'%Y-%m-%d %H:%M:%S')]: try fetch \"${FETCH_NAME}\" in \"${FETCH_DIR}\"...";

# git fetch
		git_fetch "${FETCH_DIR}";
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			echo "skip repo";
		else
			echo "to be build";


# build docker images and push to registry
			BUILD_STATUS="0"
			BUILD_LIST_INDEX=0;
			BUILD_LIST_COUNT=$(cat ${CI_CD_CONFIG} | jq "${TEMPLATE_FETCH}.build_list | length");
			while true;
			do
#				echo ".....................................................................................................................";
				TEMPLATE_BUILD="${TEMPLATE_FETCH}.build_list[${BUILD_LIST_INDEX}]";
				BUILD_NAME=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_BUILD}.name");
				BUILD_DIR=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_BUILD}.dir");

#				echo "BUILD_NAME:${BUILD_NAME}";
#				echo "BUILD_DIR:${BUILD_DIR}";
				echo -e "\n[$(date +'%Y-%m-%d %H:%M:%S')]: try build \"${BUILD_NAME}\" in \"${BUILD_DIR}\"...";


				export DOCKER_DIR="${BUILD_DIR}";
				export DOCKER_NOTIFY_MSG="${BUILD_NAME}";
				echo "docker_tool.sh f;";
				docker_tool.sh f; # save hash only if build is ok
				STATUS="${?}";
				if [ "${STATUS}" != "0" ];
				then
					BUILD_STATUS="${STATUS}";
				fi


				(( BUILD_LIST_INDEX++ ));
				if [ ${BUILD_LIST_INDEX} -eq ${BUILD_LIST_COUNT} ];
				then
					break;
				fi
			done


# was all builds ok?
			if [ "${BUILD_STATUS}" == "0" ];
			then
				git_save_hash "${FETCH_DIR}"; # ignore exit code
			fi
		fi


		(( FETCH_LIST_INDEX++ ));
		if [ ${FETCH_LIST_INDEX} -eq ${FETCH_LIST_COUNT} ];
		then
			break;
		fi
	done


# deploy
	DEPLOY_LIST_INDEX=0;
	DEPLOY_LIST_COUNT=$(cat ${CI_CD_CONFIG} | jq '.deploy_list | length');
	while true;
	do
#		echo "=====================================================================================================================";
		TEMPLATE_DEPLOY=".deploy_list[${DEPLOY_LIST_INDEX}]";
		DEPLOY_NAME=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_DEPLOY}.name");
		DEPLOY_DIR=$(cat ${CI_CD_CONFIG} | jq -r "${TEMPLATE_DEPLOY}.dir");

#		echo "DEPLOY_NAME:${DEPLOY_NAME}";
#		echo "DEPLOY_DIR:${DEPLOY_DIR}";
		echo -e "\n[$(date +'%Y-%m-%d %H:%M:%S')]: try deploy \"${DEPLOY_NAME}\" in \"${DEPLOY_DIR}\"...";


		export DOCKER_DIR="${DEPLOY_DIR}";
		export DOCKER_NOTIFY_MSG="${DEPLOY_NAME}";
		echo "docker_tool.sh deploy;";
		docker_tool.sh deploy; # skip return status code


		(( DEPLOY_LIST_INDEX++ ));
		if [ ${DEPLOY_LIST_INDEX} -eq ${DEPLOY_LIST_COUNT} ];
		then
			break;
		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# help function
function help()
{
	echo "\$ cat /somedir/ci_cd.json";
	echo "{";
	echo "  \"telegram\": {";
	echo "    \"bot_token\": \"TELEGRAM_BOT_TOKEN\",";
	echo "    \"chat_id\": \"TELEGRAM_CHAT_ID\"";
	echo "  },";
	echo "  \"docker_registry\": {";
	echo "    \"host\": \"127.0.0.1:5000\",";
	echo "    \"login\": \"\",";
	echo "    \"password\": \"\"";
	echo "  },";
	echo "  \"fetch_list\": [";
	echo "    {";
	echo "      \"name\": \"NAME_FOR_TELEGRAM_NOTIFY\",";
	echo "      \"dir\": \"SPECIAL_DIR_WITH_CLONE_GIT_REPO_FOR_PULL_ONLY__YOU_CAN_NOT_COMMIT_AND_PUSH_AND_OTHER_HERE__!!!\",";
	echo "      \"build_list\": [";
	echo "        {";
	echo "          \"name\": \"NAME_FOR_TELEGRAM_NOTIFY\",";
	echo "          \"dir\": \"DOCKER_BUILD_DIR\"";
	echo "        }";
	echo "      ]";
	echo "    }";
	echo "  ],";
	echo "  \"deploy_list\": [";
	echo "    {";
	echo "      \"name\": \"NAME_FOR_TELEGRAM_NOTIFY\",";
	echo "      \"dir\": \"DOCKER_COMPOSE_DIR\"";
	echo "    }";
	echo "  ]";
	echo "}";
	echo "\$ export CI_CD_CONFIG='/somedir/ci_cd.json';";
	echo "\$ ${1};";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "cat docker_tool.sh echo git hexdump jq notify_telegram.sh shasum";
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

	if [ "${CI_CD_CONFIG}" == "" ];
	then
		echo "ERROR: CI_CD_CONFIG is not set";
		return 1;
	fi

	if [ ! -f "${CI_CD_CONFIG}" ];
	then
		echo "ERROR: file from CI_CD_CONFIG is not found";
		return 1;
	fi

#	if [ "${CI_CD_NOTIFY}" == "" ];
#	then
#		echo "ERROR: CI_CD_NOTIFY is not set";
#		return 1;
#	fi
#	export DOCKER_NOTIFY="${CI_CD_NOTIFY}";
	export DOCKER_NOTIFY='notify_telegram.sh';


	ci_cd;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
