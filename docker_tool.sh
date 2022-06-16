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


# get hash of image
	echo "docker inspect --format='{{index .RepoDigests 0}}' ${DOCKER_IMAGE_TAG}";
	DOCKER_IMAGE_URL=$(docker inspect --format='{{index .RepoDigests 0}}' "${DOCKER_IMAGE_TAG}");
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker inspect";
		return 1;
	fi


	echo "made ${DOCKER_IMAGE_URL}";


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


# get iamge name
	local DOCKER_IMAGE_NAME=$(echo ${DOCKER_IMAGE_TAG} | sed -e 's/:.*//g')


# build
	echo "docker build --no-cache --tag ${DOCKER_IMAGE_TAG} --tag ${DOCKER_IMAGE_NAME}:latest ./;";
	docker build --no-cache --tag "${DOCKER_IMAGE_TAG}" ./ &> /dev/null < /dev/null
	if [ "${?}" != "0" ];
	then
		echo "ERROR: docker build";
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
	echo "docker-compose -f ${DOCKER_COMPOSE_FILE} ps;";
	docker-compose -f "${DOCKER_COMPOSE_FILE}" ps;
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
	echo "docker-compose -f ${DOCKER_COMPOSE_FILE} up -d --force-recreate --always-recreate-deps;";
	docker-compose -f "${DOCKER_COMPOSE_FILE}" up -d --force-recreate --always-recreate-deps; # skip --env-file ./.env
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
	echo "docker-compose -f ${DOCKER_COMPOSE_FILE} down --remove-orphans -t ${DOCKER_SHUTDOWN_TIMEOUT};";
	docker-compose -f "${DOCKER_COMPOSE_FILE}" down --remove-orphans -t "${DOCKER_SHUTDOWN_TIMEOUT}"; # skip --env-file ./.env
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
	echo "example: ${1} [ login | push DOCKER_IMAGE | build | ps | up | down ]";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local ARG="${2}";
	local STATUS;


# check operation
	if [ "${OPERATION}" != "login" ] && [ "${OPERATION}" != "push" ] && [ "${OPERATION}" != "build" ] && [ "${OPERATION}" != "ps" ] && [ "${OPERATION}" != "up" ] && [ "${OPERATION}" != "down" ];
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


# is file with variables exist?
	if [ ! -e ./.env ];
	then
		echo "ERROR: you must make .env file";
		return 1;
	fi


# load enviroment variables
	export $(cat .env);


# select operation
	if [ "${OPERATION}" == "login" ]
	then
		docker_login;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "push" ]
	then
		docker_push "${ARG}";
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "build" ]
	then
		docker_build;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "ps" ]
	then
		docker_ps;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "up" ]
	then
		docker_up;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "down" ]
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