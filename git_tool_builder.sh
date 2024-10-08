#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
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
function git_builder()
{
	local STATUS;


# set dir if it need
	if [ "${DOCKER_DIR}" == "" ];
	then
		DOCKER_DIR="./";
	fi


# try fetch
	echo "git_tool_fetcher.sh";
	git_tool_fetcher.sh "${DOCKER_DIR}";
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


# build docker image and push to registry
	echo "docker_tool.sh";
	docker_tool.sh f;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# show help
function help()
{
	echo "example: ${1}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local STATUS;


# check depends tools
	check_prog "git_tool_fetcher.sh docker_tool.sh";
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


# do it
	git_builder;
	STATUS="${?}";
	if [ "${STATUS}" != "0" ];
	then
		return "${STATUS}";
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
