#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function check_new_commit()
{
	local LOCAL_TMPDIR="/tmp";
	local a;
	local b;
	local HASH1;
	local HASH2;


# is it git repo?
	if [ ! -d ".git" ];
	then
		echo "ERROR: it is not git repo";
		return 1;
	fi


# create temp dir and files
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi


# create temp files
	TMP1=$(mktemp --tmpdir="${LOCAL_TMPDIR}");
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not make temp file";
		return 1;
	fi

	TMP2=$(mktemp --tmpdir="${LOCAL_TMPDIR}");
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not make temp file";
		rm -rf -- "${TMP1}" &> /dev/null;
		return 1;
	fi


# get old commit
	git rev-parse HEAD &> "${TMP1}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not get old commit";
		rm -rf -- "${TMP1}" &> /dev/null;
		rm -rf -- "${TMP2}" &> /dev/null;
		return 1;
	fi


# fetch
	git fetch -a &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not fetch repo";
		rm -rf -- "${TMP1}" &> /dev/null;
		rm -rf -- "${TMP2}" &> /dev/null;
		return 1;
	fi


# pull
	git pull &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not pull repo";
		rm -rf -- "${TMP1}" &> /dev/null;
		rm -rf -- "${TMP2}" &> /dev/null;
		return 1;
	fi


# pull submodules
	git submodule update --quiet --init --recursive &> /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not update submodules";
		rm -rf -- "${TMP1}" &> /dev/null;
		rm -rf -- "${TMP2}" &> /dev/null;
		return 1;
	fi


# get new commit
	git rev-parse HEAD &> "${TMP2}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not get new commit";
		rm -rf -- "${TMP1}" &> /dev/null;
		rm -rf -- "${TMP2}" &> /dev/null;
		return 1;
	fi


# get old and new commits
	HASH1=$(shasum -a 1 "${TMP1}" | { read a b; echo "${a}"; });
	HASH2=$(shasum -a 1 "${TMP2}" | { read a b; echo "${a}"; });


# delete temp files
	rm -rf "${TMP1}" &> /dev/null < /dev/null;
	rm -rf "${TMP2}" &> /dev/null < /dev/null;


# compare old and new commits
	if [ "${HASH1}" == "${HASH2}" ];
	then
		return 2;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function deploy()
{
	local STATUS;
	local TARGET_DIR;
	local MSG;


# get args
	TARGET_DIR="${1}";
	MSG="${2}";


# go to target dir
	cd -- "${TARGET_DIR}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: target dir is not found";
		return 1;
	fi


# check new commit
	check_new_commit &> /dev/null;
	STATUS="${?}";
	if [ "${STATUS}" == "1" ];
	then
		return "${STATUS}";
	fi
	if [ "${STATUS}" == "2" ];
	then
		return "${STATUS}";
	fi


# deploy
	echo "deploy for ${TARGET_DIR}";


	return "${STATUS}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local STATUS;
	local TARGET_DIR;
	local MSG;

	TARGET_DIR="${1}";
	MSG="${2}";

	date '+%Y:%m:%d %H:%M:%S';

	deploy "${TARGET_DIR}" "${MSG}";
	STATUS="${?}";

	return "${STATUS}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
