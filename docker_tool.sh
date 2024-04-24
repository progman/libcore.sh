#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.2.1
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
# change dir if it need
function change_dir()
{
# set dir if it need
	if [ "${DOCKER_DIR}" == "" ];
	then
		return 0;
	fi


# go to docker dir
	if [ ! -d "${DOCKER_DIR}" ];
	then
		echo "ERROR: docker dir is not found";
		return 1;
	fi
	cd -- "${DOCKER_DIR}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker dir is not change";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# source is not export vars from file...
# export doesn't work well with comments...
# so we use a great alterative!
function export_source()
{
# make tmp files
	local temp_file1=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	local temp_file2=$(mktemp)
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	local temp_file3=$(mktemp)
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		echo "ERROR: can't make tmp file";
		return 1;
	fi

	local temp_file4=$(mktemp)
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		echo "ERROR: can't make tmp file";
		return 1;
	fi


# get list of all vars
	unset _;
	typeset -p > "${temp_file1}";
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: can't make env list";
		return 1;
	fi


# is file exist?
	if [ ! -f "${1}" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: file \"${1}\" is not found";
		return 1;
	fi


# get local vars (if without export) from file
	source "${1}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: can't load file \"${1}\"";
		return 1;
	fi


# get list of all vars
	unset _;
	typeset -p > "${temp_file2}";
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: can't make env list";
		return 1;
	fi


# get diff between lists
	while IFS= read -r line;
	do
		if ! grep -qF "$line" "${temp_file1}";
		then
			echo "${line}" >> "${temp_file3}" # add to temp_file3 line from temp_file2 if it not exist in temp_file1
			if [ "${?}" != "0" ];
			then
				rm -f "${temp_file1}" &> /dev/null < /dev/null;
				rm -f "${temp_file2}" &> /dev/null < /dev/null;
				rm -f "${temp_file3}" &> /dev/null < /dev/null;
				rm -f "${temp_file4}" &> /dev/null < /dev/null;
				echo "ERROR: can't make diff between lists";
				return 1;
			fi
		fi
	done < "${temp_file2}";


# replace from declare to export
	sed -e 's/^declare\ [a-ZA-Z-]*/export/g' "${temp_file3}" > "${temp_file4}";
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: can't make export list";
		return 1;
	fi


# do safe export
	source "${temp_file4}" &> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -f "${temp_file1}" &> /dev/null < /dev/null;
		rm -f "${temp_file2}" &> /dev/null < /dev/null;
		rm -f "${temp_file3}" &> /dev/null < /dev/null;
		rm -f "${temp_file4}" &> /dev/null < /dev/null;
		echo "ERROR: can't load export list";
		return 1;
	fi


# rm tmp files
	rm -f "${temp_file1}" &> /dev/null < /dev/null;
	rm -f "${temp_file2}" &> /dev/null < /dev/null;
	rm -f "${temp_file3}" &> /dev/null < /dev/null;
	rm -f "${temp_file4}" &> /dev/null < /dev/null;


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_login()
{
# are vars set?
	if [ "${DOCKER_REGISTRY_HOST}" == "" ];
	then
		echo "ERROR: you must set DOCKER_REGISTRY_HOST";
		return 1;
	fi


	if [ "${DOCKER_REGISTRY_LOGIN}" == "" ];
	then
		echo "ERROR: you must set DOCKER_REGISTRY_LOGIN";
		return 1;
	fi


	if [ "${DOCKER_REGISTRY_PASSWORD}" == "" ];
	then
		echo "ERROR: you must set DOCKER_REGISTRY_PASSWORD";
		return 1;
	fi


# login
	echo "docker login --username ${DOCKER_REGISTRY_LOGIN} --password-stdin ${DOCKER_REGISTRY_HOST};";
	echo "${DOCKER_REGISTRY_PASSWORD}" | docker login --username "${DOCKER_REGISTRY_LOGIN}" --password-stdin "${DOCKER_REGISTRY_HOST}" &> /dev/null
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker login";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_build()
{
# are vars set?
	if [ "${DOCKER_IMAGE_TAG}" == "" ];
	then
		echo "ERROR: you must set DOCKER_IMAGE_TAG";
		return 1;
	fi


	if [ "${DOCKER_REGISTRY_HOST}" == "" ];
	then
		echo "ERROR: you must set DOCKER_REGISTRY_HOST";
		return 1;
	fi


# get latest image tag
	local DOCKER_IMAGE_NAME=$(echo ${DOCKER_IMAGE_TAG} | sed -e 's/:.*//g');
	local DOCKER_IMAGE_TAG_LATEST="${DOCKER_IMAGE_NAME}:latest";


# get git environvent
	local COUNT
	local GIT_URL
	local GIT_COMMIT_HASH
	local GIT_BRANCH
	local GIT_COMMITTED

	GIT_COMMITTED="true";

	git status &> /dev/null; # is git repo?
	if [ "${?}" == "0" ];
	then
		if [ "$(git remote | grep origin | wc -l | { read COL1; echo ${COL1}; })" != "0" ];
		then
			GIT_URL=$(git remote get-url origin 2> /dev/null);
			if [ "${?}" != "0" ];
			then
				GIT_URL=$(git config -l | grep remote.origin.url | sed -e 's/remote.origin.url=//g'); # maybe get-url is not exist
			fi
		fi

		GIT_COMMIT_HASH=$(git log -1 --pretty=format:"%H");

		GIT_BRANCH=$(git branch --show-current);

		if [ "$(git status --porcelain=v2 2>&1 | wc -l | { read COUNT; echo ${COUNT}; })" != "0" ];
		then
			GIT_COMMITTED="false";
		fi
	fi


# make options
	local OPT="";

	if [ "${DOCKER_CACHE}" != "1" ];
	then
		OPT+=" --no-cache";
	fi

	OPT+=" --tag ${DOCKER_IMAGE_TAG}";
	OPT+=" --tag ${DOCKER_IMAGE_TAG_LATEST}";

	if [ "${GIT_URL}" != "" ];
	then
		OPT+=" --label GIT_URL=${GIT_URL}";
	fi

	if [ "${GIT_COMMIT_HASH}" != "" ];
	then
		OPT+=" --label GIT_COMMIT_HASH=${GIT_COMMIT_HASH}";
	fi

	if [ "${GIT_BRANCH}" != "" ];
	then
		OPT+=" --label GIT_BRANCH=${GIT_BRANCH}";
	fi

	if [ "${GIT_COMMITTED}" != "" ];
	then
		OPT+=" --label GIT_COMMITTED=${GIT_COMMITTED}";
	fi


# build
	echo "docker build${OPT} ./;"
	docker build${OPT} ./ &> /dev/null < /dev/null
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker build";
		return 1;
	fi


# get hash of image
	echo "docker inspect --format='{{.Id}}' ${DOCKER_IMAGE_TAG}";
	DOCKER_IMAGE_HASH=$(docker inspect --format='{{.Id}}' "${DOCKER_IMAGE_TAG}");
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker inspect";
		return 1;
	fi


	echo "made ${DOCKER_IMAGE_NAME}@${DOCKER_IMAGE_HASH}";
	echo "made ${DOCKER_IMAGE_TAG_LATEST}"


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_push()
{
	local DOCKER_IMAGE_TAG="${1}";
	local HASH_SOURCE;
	local HASH_TARGET;


# are vars set?
	if [ "${DOCKER_IMAGE_TAG}" == "" ];
	then
		echo "ERROR: you must set DOCKER_IMAGE_TAG";
		return 1;
	fi


	if [ "${DOCKER_REGISTRY_HOST}" == "" ];
	then
		echo "ERROR: you must set DOCKER_REGISTRY_HOST";
		return 1;
	fi


# get latest image tag
	local DOCKER_IMAGE_NAME=$(echo ${DOCKER_IMAGE_TAG} | sed -e 's/:.*//g');
	local DOCKER_IMAGE_TAG_LATEST="${DOCKER_IMAGE_NAME}:latest";


# get hash
	echo "docker image list --no-trunc ${DOCKER_IMAGE_TAG} --format \"{{lower .ID}}\";";
	HASH_SOURCE=$(docker image list --no-trunc "${DOCKER_IMAGE_TAG}" --format "{{lower .ID}}");
#	echo "HASH_SOURCE:${HASH_SOURCE}";


# push and check
	while true;
	do


# unset tag (maybe image uses)
		echo "docker rmi -f ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG};";
		docker rmi -f "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker tag";
			return 1;
		fi


# set tag
		echo "docker tag ${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG};";
		docker tag "${DOCKER_IMAGE_TAG}" "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker tag";
			return 1;
		fi


# push to registry
		echo "docker push ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG};";
		docker push "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker push, did you login to registry?";
			return 1;
		fi


# check hash
		echo "docker image list --no-trunc ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG} --format \"{{lower .ID}}\";";
		HASH_TARGET=$(docker image list --no-trunc "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" --format "{{lower .ID}}");
#		echo "HASH_TARGET:${HASH_TARGET}";


# compare hashes
		if [ "${HASH_SOURCE}" == "${HASH_TARGET}" ];
		then
			break
		fi
		echo "try again...";
	done


# get hash
	echo "docker image list --no-trunc ${DOCKER_IMAGE_TAG_LATEST} --format \"{{lower .ID}}\";";
	HASH_SOURCE=$(docker image list --no-trunc "${DOCKER_IMAGE_TAG_LATEST}" --format "{{lower .ID}}");
#	echo "HASH_SOURCE:${HASH_SOURCE}";


# push and check
	while true;
	do


# unset tag (maybe image uses)
		echo "docker rmi -f ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST};";
		docker rmi -f "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker tag";
			return 1;
		fi


# set tag
		echo "docker tag ${DOCKER_IMAGE_TAG_LATEST} ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST};";
		docker tag "${DOCKER_IMAGE_TAG_LATEST}" "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker tag";
			return 1;
		fi


# push to registry
		echo "docker push ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST};";
		docker push "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST}" &> /dev/null < /dev/null
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker push, did you login to registry?";
			return 1;
		fi


# check hash
		echo "docker image list --no-trunc ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST} --format \"{{lower .ID}}\";";
		HASH_TARGET=$(docker image list --no-trunc "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST}" --format "{{lower .ID}}");
#		echo "HASH_TARGET:${HASH_TARGET}";


# compare hashes
		if [ "${HASH_SOURCE}" == "${HASH_TARGET}" ];
		then
			break
		fi
		echo "try again...";
	done


# get hash of image
	echo "docker inspect --format='{{index .RepoDigests 0}}' ${DOCKER_IMAGE_TAG}";
	DOCKER_IMAGE_URL=$(docker inspect --format='{{index .RepoDigests 0}}' "${DOCKER_IMAGE_TAG}");
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker inspect";
		return 1;
	fi


	echo "made ${DOCKER_IMAGE_URL}";
	echo "made ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG_LATEST}"


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_flush()
{
# build
	docker_build;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# push
	docker_push "${DOCKER_IMAGE_TAG}";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


#	echo "flush go baby go";
	if [ "${DOCKER_NOTIFY}" != "" ] && [ "${DOCKER_NOTIFY_MSG}" != "" ];
	then
		"${DOCKER_NOTIFY}" "${DOCKER_NOTIFY_MSG}" &> /dev/null < /dev/null &
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_ps()
{
# are vars set?
	if [ "${DOCKER_PROJECT_NAME}" == "" ];
	then
		if [ "${COMPOSE_PROJECT_NAME}" != "" ];
		then
			DOCKER_PROJECT_NAME="${COMPOSE_PROJECT_NAME}";
		else
			DOCKER_PROJECT_NAME=$(pwd | sed -e 's/.*\///g');
		fi
	fi


# set name of docker compose config
	DOCKER_COMPOSE_FILE="";
	if [ -e ./docker-compose.yml ] || [ -e ./docker-compose.yaml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yml";
		if [ ! -e ./docker-compose.yml ];
		then
			DOCKER_COMPOSE_FILE="./docker-compose.yaml";
		fi
	fi


# ps
	if [ "${DOCKER_COMPOSE_FILE}" != "" ];
	then
		echo "docker compose --project-name ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} ps --format \"table {{lower .ID}}\t{{lower .Names}}\t{{lower .Status}}\";";
		docker compose --project-name ${DOCKER_PROJECT_NAME} -f "${DOCKER_COMPOSE_FILE}" ps --format "table {{lower .ID}}\t{{lower .Names}}\t{{lower .Status}}";
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker compose ps";
			return 1;
		fi
	else
		echo "docker ps --format \"table {{lower .ID}}\t{{lower .Names}}\t{{lower .Status}}\";";
		docker ps --format "table {{lower .ID}}\t{{lower .Names}}\t{{lower .Status}}";
		if [ "${?}" != "0" ];
		then
			echo "ERROR: docker compose ps";
			return 1;
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_pull()
{
	local DOCKER_COMPOSE_FILE;
	local STATUS;


# are vars set?
	if [ "${DOCKER_PROJECT_NAME}" == "" ];
	then
		if [ "${COMPOSE_PROJECT_NAME}" != "" ];
		then
			DOCKER_PROJECT_NAME="${COMPOSE_PROJECT_NAME}";
		else
			DOCKER_PROJECT_NAME=$(pwd | sed -e 's/.*\///g');
		fi
	fi


# is docker compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# pull
	echo "docker compose -f ${DOCKER_COMPOSE_FILE} pull --quiet;"; # skip --env-file ./.env
	docker compose -f "${DOCKER_COMPOSE_FILE}" pull --quiet;
	if [ "${?}" != "0" ];
	then
		rm -f "${TMP}" &> /dev/null < /dev/null;
		echo "ERROR: docker compose pull";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_test()
{
	local DOCKER_COMPOSE_FILE;
	local STATUS;
	local TEST_STATUS;
	local ID;
	local TEST_CONTAINER;
	local TEST_COMMAND;


# are vars set?
	if [ "${DOCKER_PROJECT_NAME}" == "" ];
	then
		if [ "${COMPOSE_PROJECT_NAME}" != "" ];
		then
			DOCKER_PROJECT_NAME="${COMPOSE_PROJECT_NAME}";
		else
			DOCKER_PROJECT_NAME=$(pwd | sed -e 's/.*\///g');
		fi
	fi


# is docker compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# up
	FLAG_PULL="1";
	docker_up &> /dev/null < /dev/null;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


# scan all containers from this docker-compose.yml and looking for "test.container"="true" and "test.command"="who we must start"
	for ID in $(docker compose --project-name "${DOCKER_PROJECT_NAME}" -f "${DOCKER_COMPOSE_FILE}" ps --format "{{lower .ID}}");
	do
		TEST_CONTAINER=$(docker inspect --format '{{ index .Config.Labels "test.container"}}' "${ID}");
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			return "${STATUS}";
		fi


		TEST_COMMAND=$(docker inspect --format '{{ index .Config.Labels "test.command"}}' "${ID}");
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			return "${STATUS}";
		fi


		if [ "${TEST_CONTAINER}" == "true" ];
		then
			break;
		fi
	done


# run test if test container is found
	if [ "${TEST_CONTAINER}" == "true" ];
	then
		docker exec -it ${ID} ${TEST_COMMAND};
		TEST_STATUS="${?}";
#		echo "STATUS: ${TEST_STATUS}";


		docker stop ${ID} -t 0 &> /dev/null < /dev/null; # stop test container now
	fi


# down
	docker_down &> /dev/null < /dev/null;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


# return test status if test did run
	if [ "${TEST_CONTAINER}" == "true" ];
	then
		return "${TEST_STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_deploy()
{
	local FLAG_DEPLOY;
	local CONTAINER_NAME;
	local FLAG_LATEST;
	local COL1;
	local STATUS;
	local IMAGE;
	local HASH_OLD;
	local HASH_NEW;


# docker pull
	docker_pull;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


# is deploy need?
	FLAG_DEPLOY="0";
	for CONTAINER_NAME in $(docker compose config | grep 'container_name:' | sed -e 's/.*:\ //g');
	do
		echo "found: ${CONTAINER_NAME}";


# is container image latest?
		FLAG_LATEST=$(docker inspect --type container ${CONTAINER_NAME} | grep Image | grep latest | wc -l | { read COL1; echo ${COL1}; })
		if [ "${FLAG_LATEST}" != "0" ];
		then
			echo "found latest: ${CONTAINER_NAME}";


# get container image
			IMAGE=$(docker inspect --type container ${CONTAINER_NAME} | grep Image | grep latest | sed -e 's/:latest.*//g' | sed -e 's/.*"//g')":latest";
			echo "IMAGE: ${IMAGE}";


# get container image hash
			HASH_OLD=$(docker inspect --type container ${CONTAINER_NAME} | grep Image | grep -v latest | sed -e 's/.*\ //g' | sed -e 's/^"//g' | sed -e 's/".*//g');
			echo "HASH_OLD: ${HASH_OLD}";


# get local docker image hash
			HASH_NEW=$(docker image list --no-trunc --format "{{.ID}}" "${IMAGE}");
			echo "HASH_NEW: ${HASH_NEW}";


			if [ "${HASH_OLD}" != "${HASH_NEW}" ];
			then
				FLAG_DEPLOY="1";
				break;
			fi
		fi
	done


# ps if deploy is not need
	if [ "${FLAG_DEPLOY}" == "0" ];
	then
		docker_ps;
		STATUS="${?}";
		return "${STATUS}";
	fi


# up
	FLAG_PULL="0";
	docker_up;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


#	echo "deploy go baby go";
	if [ "${DOCKER_NOTIFY}" != "" ] && [ "${DOCKER_NOTIFY_MSG}" != "" ];
	then
		"${DOCKER_NOTIFY}" "${DOCKER_NOTIFY_MSG}" &> /dev/null < /dev/null &
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_up()
{
	local DOCKER_COMPOSE_FILE;
	local STATUS;


# are vars set?
	if [ "${DOCKER_PROJECT_NAME}" == "" ];
	then
		if [ "${COMPOSE_PROJECT_NAME}" != "" ];
		then
			DOCKER_PROJECT_NAME="${COMPOSE_PROJECT_NAME}";
		else
			DOCKER_PROJECT_NAME=$(pwd | sed -e 's/.*\///g');
		fi
	fi


# is docker compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# pull
	if [ "${FLAG_PULL}" == "1" ];
	then
		docker_pull;
		STATUS="${?}";
		if [ "${STATUS}" != "0" ];
		then
			return "${STATUS}";
		fi
	fi


# make options
	local OPT="";
	OPT+=" --project-name ${DOCKER_PROJECT_NAME}";
	OPT+=" -f ${DOCKER_COMPOSE_FILE}";
	OPT+=" up";
	OPT+=" --renew-anon-volumes";
	OPT+=" --always-recreate-deps";
#	OPT+=" --env-file ./.env";

	if [ "${DOCKER_CACHE}" == "1" ];
	then
		OPT+=" --force-recreate";
	fi

	OPT+=" -d";


# up
	echo "docker compose${OPT};";
	docker compose${OPT};
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker compose up";
		return 1;
	fi


# ps
	docker_ps;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_down()
{
# are vars set?
	if [ "${DOCKER_PROJECT_NAME}" == "" ];
	then
		if [ "${COMPOSE_PROJECT_NAME}" != "" ];
		then
			DOCKER_PROJECT_NAME="${COMPOSE_PROJECT_NAME}";
		else
			DOCKER_PROJECT_NAME=$(pwd | sed -e 's/.*\///g');
		fi
	fi


# is docker compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# set timeout
	if [ "${DOCKER_SHUTDOWN_TIMEOUT}" == "" ];
	then
		DOCKER_SHUTDOWN_TIMEOUT=3600
	fi


# down
	echo "docker compose -p ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} down --remove-orphans -t ${DOCKER_SHUTDOWN_TIMEOUT};";
	docker compose -p "${DOCKER_PROJECT_NAME}" -f "${DOCKER_COMPOSE_FILE}" down --remove-orphans -t "${DOCKER_SHUTDOWN_TIMEOUT}"; # skip --env-file ./.env
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker compose down";
		return 1;
	fi


# ps
	docker_ps;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# show help
function help()
{
	echo "example: ${1} [ login | build, b | pull | push DOCKER_IMAGE | flush, f | ps | test, t | deploy | up, u | down, d ]";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local ARG="${2}";
	local STATUS;
	local FLAG_DEBUG="1";


# check operation
	if [ "${OPERATION}" != "login" ]  && \
	   [ "${OPERATION}" != "build" ]  && [ "${OPERATION}" != "b" ] && \
	   [ "${OPERATION}" != "pull" ]   && \
	   [ "${OPERATION}" != "push" ]   && \
	   [ "${OPERATION}" != "flush" ]  && [ "${OPERATION}" != "f" ] && \
	   [ "${OPERATION}" != "ps" ]     && \
	   [ "${OPERATION}" != "test" ]   && [ "${OPERATION}" != "t" ] && \
	   [ "${OPERATION}" != "deploy" ] && \
	   [ "${OPERATION}" != "up" ]     && [ "${OPERATION}" != "u" ] && \
	   [ "${OPERATION}" != "down" ]   && [ "${OPERATION}" != "d" ];
	then
		help "${0}";
		return 0;
	fi


# disable debug for test
	if [ "${OPERATION}" == "test" ] || [ "${OPERATION}" == "t" ];
	then
		FLAG_DEBUG="0";
	fi


# check depends tools
	check_prog "docker";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# change dir if it need
	change_dir;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


# load enviroment variables
	if [ ! -f .env ] && [ ! -d .env ];
	then
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "skip .env";
		fi
	else
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "export .env";
		fi
		if [ -f .env ];
		then
			export_source .env;
			if [ "${?}" != "0" ];
			then
				return 1;
			fi
		fi
		if [ -d .env ];
		then
			for FILE in $(find .env -type f);
			do
				export_source "${FILE}";
				if [ "${?}" != "0" ];
				then
					return 1;
				fi
			done
		fi
	fi


# load enviroment variables
	if [ ! -f .env.local ] && [ ! -d .env.local ];
	then
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "skip .env.local";
		fi
	else
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "export .env.local";
		fi
		if [ -f .env.local ];
		then
			export_source .env.local;
			if [ "${?}" != "0" ];
			then
				return 1;
			fi
		fi
		if [ -d .env.local ];
		then
			for FILE in $(find .env.local -type f);
			do
				export_source "${FILE}";
				if [ "${?}" != "0" ];
				then
					return 1;
				fi
			done
		fi
	fi


# check if env from example is exist
	if [ ! -f ./.env.example ];
	then
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "skip .env.example";
		fi
	else
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "use .env.example";
		fi
		while read -e ENV;
		do
			if [ $(export -p | sed -e 's/^declare\ [a-ZA-Z-]*\ //g' | grep "^${ENV}=" | wc -l) != 1 ]; # is env exported?
			then
				echo "ERROR: environment variable \"${ENV}\" must be set (see .env.example)";
				return 1;
			fi
		done <<< $(cat ./.env.example | sed -e 's/#.*//g' | grep '=' | sed -e 's/=.*//g');
	fi


# select operation
	if [ "${OPERATION}" == "login" ]
	then
		docker_login;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "build" ] || [ "${OPERATION}" == "b" ]
	then
		docker_build;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "pull" ]
	then
		docker_pull "${ARG}";
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "push" ]
	then
		docker_push "${ARG}";
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "flush" ] || [ "${OPERATION}" == "f" ]
	then
		docker_flush;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "ps" ]
	then
		docker_ps;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "test" ] || [ "${OPERATION}" == "t" ]
	then
		docker_test;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "deploy" ]
	then
		docker_deploy;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "up" ] || [ "${OPERATION}" == "u" ]
	then
		FLAG_PULL="1";
		docker_up;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "down" ] || [ "${OPERATION}" == "d" ]
	then
		docker_down;
		STATUS="${?}";
		return "${STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
