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
# find file
function find_file()
{
	if [ ! -f "${2}" ];
	then
		echo "- ERROR: file not found \"${2}\"";
		return 1;
	fi

	local HASH=$(git hash-object "${2}");


# save current dir
	DIR_CUR="${PWD}";
	cd -- "${1}";



# create file for filelist
	local TMP1;
	TMP1=$(mktemp);
	if [ "${?}" != "0" ];
	then
		echo "FATAL: can't make tmp file";
		return 1;
	fi


	git rev-list --all &> "${TMP1}";


	while read -r COMMIT;
	do
		if [ "$(git ls-tree -r "${COMMIT}" | grep "${HASH}" | grep blob | wc -l)" != "0" ];
		then
			echo "+ found commit ${COMMIT} for \"${2}\"";
			cd -- "${DIR_CUR}";
			rm -rf -- "${TMP1}" &> /dev/null;
			return 0;
		fi

	done < "${TMP1}";


	echo "- ERROR: commit not found for \"${2}\"";


	cd -- "${DIR_CUR}";
	rm -rf -- "${TMP1}" &> /dev/null;


	return 1;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view help
function help()
{
	echo "example: ${0} GITDIR FILE...";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local FILE_COUNT="${#}";
	if [ ${FILE_COUNT} -lt 2 ]; # ${FILE_COUNT} < 2
	then
		help "${@}";
		return 1;
	fi
	(( FILE_COUNT-- ));


	local GIT="${1}";


	if [ ! -d "${1}" ];
	then
		help "${@}";
		return 1;
	fi


# check depends tools
	check_prog "echo git grep head wc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi



	while true;
	do
		find_file "${GIT}" "${2}";

		(( FILE_COUNT-- ));
		shift 1;

		if [ "${FILE_COUNT}" == "0" ];
		then
			break;
		fi
	done


	return "${?}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
