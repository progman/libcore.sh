#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.1
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	if [ ! -d "${1}" ];
	then
		echo "example: ${0} DIR";
		echo "find Git repos with untracked or modified files";
		return 1;
	fi


# check minimal depends tools
	check_prog "echo find git grep mktemp rm sed wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# save current dir
	local DIR_CUR="${PWD}";


# create tmp file
	local TMP1;
	TMP1="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi


# create tmp file
	local TMP2;
	TMP2="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		rm -rf -- "${TMP1}";
		return 1;
	fi


# create branch list for dir1
	cd -- "${1}";


# search git dir
	find "${PWD}" -type d -name '.git' | sed -e 's/.git$//g' >> "${TMP1}";


# check git dir list
	while read -r DIR;
	do
		cd -- "${DIR_CUR}";
		cd -- "${DIR}";


		local BRANCH="$(git branch 2>/dev/null | grep '^\*' | sed -e 's/^\*\ //g')";
		if [ "${BRANCH}" == "" ];
		then
			continue;
		fi


		local GIT_STATUS="";
		while true;
		do
			$(git status --porcelain --ignore-submodules 2> /dev/null > "${TMP2}");
			if [ "${?}" != "0" ];
			then
				GIT_STATUS="(?)";
				break;
			fi

			if [ "$(grep -v '^??' "${TMP2}" | grep -v '^AD' | wc -l)" != "0" ];
			then
				GIT_STATUS="(+)";
				break;
			fi

			if [ "$(grep '^??' "${TMP2}" | wc -l)" != "0" ] && [ "${GITBASH_FLAG_UNTRACKED}" != "false" ];
			then
				GIT_STATUS="(-)";
				break;
			fi

			break;
		done

		echo "${GIT_STATUS}${PWD}";

	done < "${TMP1}";


	cd -- "${DIR_CUR}";
	rm -rf -- "${TMP1}";
	rm -rf -- "${TMP2}";


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
