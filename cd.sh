#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# echo "alias  d='. cd.sh --load dev_path';" >> ~/.bashrc;
# echo "alias ds='. cd.sh --save dev_path';" >> ~/.bashrc;
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view help
function help()
{
	PROGNAME="${0}";

	if [ "$(which basename)" != "" ];
	then
		PROGNAME="$(basename ${0})";
	fi

	echo "${PROGNAME} --load|--save FILE";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check args
	if [ "${2}" == "" ];
	then
		help;
		return;
	fi

	if [ "${1}" != "--save" ] && [ "${1}" != "--load" ];
	then
		help;
		return;
	fi


# get config dir
	DIR_CONFIG="${XDG_CONFIG_HOME}";
	if [ ! -d "${DIR_CONFIG}" ];
	then
		DIR_CONFIG="${HOME}/.config/";
		if [ ! -d "${DIR_CONFIG}" ];
		then
			mkdir -m 0700 ~/.config &> /dev/null;
		fi
	fi


# save current dir
	if [ "${1}" == "--save" ];
	then
		echo "${PWD}" > "${DIR_CONFIG}/${2}";
	fi


# load old dir
	if [ "${1}" == "--load" ];
	then
		if [ -f "${DIR_CONFIG}/${2}" ];
		then
			DIR="$(cat ${DIR_CONFIG}/${2})";
			if [ -d "${DIR}" ];
			then
				cd "${DIR}";
			fi
		fi
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${1}" "${2}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
