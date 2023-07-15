#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.1
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
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
	local GIT_URL
	local GIT_COMMIT_HASH
	local GIT_BRANCH

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
	fi


# make options
	local OPT="";

	if [ "${DOCKER_CACHE}" == "1" ];
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


# set tag
	echo "docker tag ${DOCKER_IMAGE_TAG} ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG};";
	docker tag "${DOCKER_IMAGE_TAG}" "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" &> /dev/null < /dev/null
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
	echo "docker push ${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG};";
	docker push "${DOCKER_REGISTRY_HOST}/${DOCKER_IMAGE_TAG}" &> /dev/null < /dev/null
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker push, did you login to registry?";
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


# is docker-compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker-compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# ps
	echo "docker-compose -p ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} ps;";
	docker-compose -p ${DOCKER_PROJECT_NAME} -f "${DOCKER_COMPOSE_FILE}" ps;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker-compose ps";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function docker_up()
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


# is docker-compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker-compose config
	DOCKER_COMPOSE_FILE="./docker-compose.yml";
	if [ ! -e ./docker-compose.yml ];
	then
		DOCKER_COMPOSE_FILE="./docker-compose.yaml";
	fi


# pull
	echo "docker-compose -f ${DOCKER_COMPOSE_FILE} pull --quiet;";
	docker-compose -f "${DOCKER_COMPOSE_FILE}" pull --quiet; # skip --env-file ./.env
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker-compose pull";
		return 1;
	fi


# up
	if [ "${DOCKER_CACHE}" == "1" ];
	then
		echo "docker-compose -p ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} up -d --renew-anon-volumes --always-recreate-deps;";
		docker-compose -p "${DOCKER_PROJECT_NAME}" -f "${DOCKER_COMPOSE_FILE}" up -d --renew-anon-volumes --always-recreate-deps; # skip --env-file ./.env
	else
		echo "docker-compose -p ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} up -d --renew-anon-volumes --always-recreate-deps --force-recreate;";
		docker-compose -p "${DOCKER_PROJECT_NAME}" -f "${DOCKER_COMPOSE_FILE}" up -d --renew-anon-volumes --always-recreate-deps --force-recreate; # skip --env-file ./.env
	fi
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker-compose up";
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


# is docker-compose config exist?
	if [ ! -e ./docker-compose.yml ] && [ ! -e ./docker-compose.yaml ];
	then
		echo "ERROR: you must make docker-compose.yml file";
		return 1;
	fi


# set name of docker-compose config
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
	echo "docker-compose -p ${DOCKER_PROJECT_NAME} -f ${DOCKER_COMPOSE_FILE} down --remove-orphans -t ${DOCKER_SHUTDOWN_TIMEOUT};";
	docker-compose -p "${DOCKER_PROJECT_NAME}" -f "${DOCKER_COMPOSE_FILE}" down --remove-orphans -t "${DOCKER_SHUTDOWN_TIMEOUT}"; # skip --env-file ./.env
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker-compose down";
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
# show help
function help()
{
	echo "example: ${1} [ login | build | push DOCKER_IMAGE | flush | ps | up | down ]";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local ARG="${2}";
	local STATUS;


# check operation
	if [ "${OPERATION}" != "login" ] && \
	   [ "${OPERATION}" != "build" ] && [ "${OPERATION}" != "b" ] && \
	   [ "${OPERATION}" != "push" ] && \
	   [ "${OPERATION}" != "flush" ] && [ "${OPERATION}" != "f" ] && \
	   [ "${OPERATION}" != "ps" ] && \
	   [ "${OPERATION}" != "up" ] && [ "${OPERATION}" != "u" ] && \
	   [ "${OPERATION}" != "down" ] && [ "${OPERATION}" != "d" ];
	then
		help "${0}";
		return 0;
	fi


# check depends tools
	check_prog "docker docker-compose";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# load enviroment variables
	if [ ! -f .env ];
	then
		echo "skip .env";
	else
		echo "use .env";
		source .env;
	fi


# load enviroment variables
	if [ ! -f .env.local ];
	then
		echo "skip .env.local";
	else
		echo "use .env.local";
		source .env.local;
	fi


# check if env from example is exist
	if [ ! -f ./.env.example ];
	then
		echo "skip .env.example";
	else
		echo "use .env.example";
		while read -e ENV;
		do
			if [ ! -v ${ENV} ];
			then
				echo "ERROR: environment variable \"${ENV}\" must be set";
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


	if [ "${OPERATION}" == "up" ] || [ "${OPERATION}" == "u" ]
	then
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
