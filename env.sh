#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 1.0.0
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
	cat "${temp_file4}"
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
# show help
function help()
{
	echo "example: ${1} [ FILE | DIR ]";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local ARG="${1}";
	local STATUS;
	local FLAG_DEBUG="1";


# check operation
	if [ "${ARG}" == "--help" ] || [ "${ARG}" == "-help" ] || [ "${ARG}" == "-h" ];
	then
		help "${0}";
		return 0;
	fi


# set default
	if [ "${ARG}" == "" ];
	then
		ARG='.env';
	fi


# check depends tools
	check_prog "docker";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# load enviroment variables
	if [ ! -f ${ARG} ] && [ ! -d ${ARG} ];
	then
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "skip ${ARG}";
		fi
	else
		if [ "${FLAG_DEBUG}" == "1" ];
		then
			echo "export ${ARG}";
		fi
		if [ -f ${ARG} ];
		then
			export_source ${ARG};
			if [ "${?}" != "0" ];
			then
				return 1;
			fi
		fi
		if [ -d ${ARG} ];
		then
			for FILE in $(find ${ARG} -type f);
			do
				export_source "${FILE}";
				if [ "${?}" != "0" ];
				then
					return 1;
				fi
			done
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
