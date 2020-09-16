#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#	echo "git__clone()";
function git__clone()
{
	local REPO_URL;
	local REPO_URL_HASH;


	REPO_URL="${1}";
	REPO_URL_HASH="${2}";


	git clone "${REPO_URL}" "${REPO_URL_HASH}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not clone";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#	echo "git__merge()";
function git__merge()
{
	local REPO_URL;
	local REPO_URL_LOCAL;
	local BRANCH_SOURCE;
	local BRANCH_SOURCE_SHORT;
	local BRANCH_TARGET;
	local BRANCH_TARGET_SHORT;
	local CUR_BRANCH;


	REPO_URL="${1}";
	BRANCH_SOURCE="${2}";
	BRANCH_TARGET="${3}";


# is git repo?
	git status &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: this is not git repo";
		return 1;
	fi


# is remote url set?
	if [ "$(git remote | grep origin | wc -l | { read a; echo "${a}"; })" == "0" ];
	then
		echo "ERROR: remote url is not found";
		return 1;
	fi


# get local repo url
	REPO_URL_LOCAL=$(git remote get-url origin 2> /dev/null < /dev/null);
	if [ "${?}" != "0" ];
	then
# maybe get-url is not exist
		REPO_URL_LOCAL=$(git config -l | grep remote.origin.url | sed -e 's/remote.origin.url=//g' 2> /dev/null < /dev/null);
	fi


# compare local repo url with request repo url
	if [ "${REPO_URL_LOCAL}" != "${REPO_URL}" ];
	then
		echo "ERROR: local url is not equal with request url";
		return 1;
	fi


# get current branch
	CUR_BRANCH=$(git branch -l | grep '\*' | sed -e 's/\*//g' | sed -e 's/\ *//g');


# go to branch source
	BRANCH_SOURCE_SHORT=$(echo "${BRANCH_SOURCE}" | sed -e 's/.*\///g');
	FLAG_FOUND_BRANCH_SOURCE=$(git branch -l --no-color | sed -e 's/\*//g' | sed -e 's/\ *//g' | grep "${BRANCH_SOURCE_SHORT}" | wc -l | { read a; echo "${a}"; });
	if [ "${FLAG_FOUND_BRANCH_SOURCE}" == "0" ];
	then
		git checkout -b "${BRANCH_SOURCE_SHORT}" "${BRANCH_SOURCE}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not checkout";
			return 1;
		fi
	else
		if [ "$(git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads | grep "${BRANCH_SOURCE_SHORT} ${BRANCH_SOURCE}" | wc -l | { read a; echo "${a}"; })" == "0" ];
		then
			echo "ERROR: local branch is not link with remote branch (for source)";
			return 1;
		fi


		git checkout "${BRANCH_SOURCE_SHORT}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not checkout";
			return 1;
		fi
	fi


# fetch
	git fetch --append --prune &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_SOURCE_SHORT} branch";
		return 1;
	fi


# pull
	git pull origin "${BRANCH_SOURCE_SHORT}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_SOURCE_SHORT} branch";
		return 1;
	fi


# submodule update
	git submodule update --init --recursive &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_SOURCE_SHORT} branch";
		return 1;
	fi


# go to branch target
	BRANCH_TARGET_SHORT=$(echo "${BRANCH_TARGET}" | sed -e 's/.*\///g');
	FLAG_FOUND_BRANCH_TARGET=$(git branch -l --no-color | sed -e 's/\*//g' | sed -e 's/\ *//g' | grep "${BRANCH_TARGET_SHORT}" | wc -l | { read a; echo "${a}"; });
	if [ "${FLAG_FOUND_BRANCH_TARGET}" == "0" ];
	then
		git checkout -b "${BRANCH_TARGET_SHORT}" "${BRANCH_TARGET}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not checkout";
			return 1;
		fi
	else
		if [ "$(git for-each-ref --format='%(refname:short) %(upstream:short)' refs/heads | grep "${BRANCH_TARGET_SHORT} ${BRANCH_TARGET}" | wc -l | { read a; echo "${a}"; })" == "0" ];
		then
			echo "ERROR: local branch is not link with remote branch (for target)";
			return 1;
		fi


		git checkout "${BRANCH_TARGET_SHORT}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not checkout";
			return 1;
		fi
	fi


# fetch
	git fetch --append --prune &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_TARGET_SHORT} branch";
		return 1;
	fi


# pull
	git pull origin "${BRANCH_TARGET_SHORT}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_TARGET_SHORT} branch";
		return 1;
	fi


# submodule update
	git submodule update --init --recursive &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not rich ${BRANCH_TARGET_SHORT} branch";
		return 1;
	fi


# merge source branch to target branch
	git merge --no-ff "${BRANCH_SOURCE_SHORT}" -m "merge branch ${BRANCH_SOURCE_SHORT}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not merge ${BRANCH_SOURCE_SHORT} branch to ${BRANCH_TARGET_SHORT} branch";
		return 1;
	fi


# push changes
	git push origin "${BRANCH_TARGET_SHORT}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not push ${BRANCH_TARGET_SHORT} branch";
		return 1;
	fi


# return to old branch
	git checkout "${CUR_BRANCH}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: can not checkout";
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function help()
{
	echo "example: ${0} 'git@github.com:progman/libcore.sh.git' 'origin/dev' 'origin/tst'";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local LOCAL_TMPDIR;
	local REPO_URL;
	local REPO_URL_HASH;
	local BRANCH_SOURCE;
	local BRANCH_TARGET;
	local FLAG_BRANCH_SOURCE_REMOTE;
	local FLAG_BRANCH_TARGET_REMOTE;


# get args
	REPO_URL="${1}";
	BRANCH_SOURCE="${2}";
	BRANCH_TARGET="${3}";


# check depends tools
	check_prog "echo git grep mkdir rm sed sha3sum wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check BRANCH_SOURCE
	FLAG_BRANCH_SOURCE_REMOTE=$(echo "${BRANCH_SOURCE}" | grep -- '\/' | wc -l | { read a; echo "${a}"; });
	if [ "${FLAG_BRANCH_SOURCE_REMOTE}" == "0" ];
	then
		help "${0}";
		return 1;
	fi


# check BRANCH_TARGET
	FLAG_BRANCH_SOURCE_REMOTE=$(echo "${BRANCH_TARGET}" | grep -- '\/' | wc -l | { read a; echo "${a}"; });
	if [ "${FLAG_BRANCH_SOURCE_REMOTE}" == "0" ];
	then
		help "${0}";
		return 1;
	fi


# make repo url hash
	REPO_URL_HASH=$(echo -n "${REPO_URL}" | sha3sum | { read a b; echo ${a}; });


#	echo "BRANCH_SOURCE: ${BRANCH_SOURCE}";
#	echo "BRANCH_TARGET: ${BRANCH_TARGET}";
#	echo "REPO_URL: ${REPO_URL}";
#	echo "REPO_URL_HASH: ${REPO_URL_HASH}";


# get temp dir
	LOCAL_TMPDIR="/tmp";
	if [ "${TMPDIR}" != "" ] && [ -d "${TMPDIR}" ];
	then
		LOCAL_TMPDIR="${TMPDIR}";
	fi


# cd to tmp dir
	cd -- "${LOCAL_TMPDIR}" &> /dev/null < /dev/null;


	if [ ! -d "git_merge_cash" ];
	then
		mkdir -- "git_merge_cash" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not make git_merge_cash dir";
			return 1;
		fi
	fi


	cd -- "git_merge_cash" &> /dev/null < /dev/null;


	while true;
	do

		if [ -d "${REPO_URL_HASH}" ];
		then
			cd -- "${REPO_URL_HASH}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: can not change dir";
				return 1;
			fi


#			echo "git__merge()";
			git__merge "${REPO_URL}" "${BRANCH_SOURCE}" "${BRANCH_TARGET}" &> /dev/null < /dev/null;
			if [ "${?}" == "0" ];
			then
				break;
			fi


			cd -- ".." &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: can not change dir";
				return 1;
			fi


#			echo "WARNING: repo is broken, cleanup";
			rm -rf "${REPO_URL_HASH}" &> /dev/null < /dev/null;
			if [ "${?}" != "0" ];
			then
				echo "ERROR: can not delete dir";
				return 1;
			fi
		fi


#		echo "git__clone()";
		git__clone "${REPO_URL}" "${REPO_URL_HASH}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not clone repo";
			return 1;
		fi


		cd -- "${REPO_URL_HASH}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not change dir";
			return 1;
		fi


#		echo "git__merge()";
		git__merge "${REPO_URL}" "${BRANCH_SOURCE}" "${BRANCH_TARGET}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR: can not merge";
			return 1;
		fi


		break;


	done


	echo "ok";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
