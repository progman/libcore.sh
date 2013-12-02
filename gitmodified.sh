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
		return 1;
	fi


# check minimal depends tools
	check_prog "echo git head grep wc sed sha1sum";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# save current dir
	DIR_CUR="${PWD}";


# create tmp file
	local TMP1;
	TMP1="$(mktemp)";
	if [ "${?}" != "0" ];
	then
		echo "can't make tmp file";
		return 1;
	fi


# create branch list for dir1
	cd -- "${1}";


# search git dir
	find "${PWD}" -type d -name '.git' | sed -e 's/.git$//g' >> "${TMP1}";


# check git dir list
	while read -r DIR;
	do

		cd "${DIR}";
		BRANCH="$(git branch 2>/dev/null | grep '^\*' | sed -e 's/^\*\ //g')";
		if [ "${BRANCH}" != "" ];
		then
			if [ "$(git status --porcelain --ignore-submodules 2>/dev/null | grep -v '^??' | grep -v '^AD' | wc -l)" != "0" ];
			then
				echo "(+)${DIR}";
			else
				if [ "$(git status --porcelain --ignore-submodules 2>/dev/null | grep '^??' | wc -l)" != "0" ];
				then
					echo "(?)${DIR}";
				fi
			fi
		fi

	done < "${TMP1}";


	cd -- "${DIR_CUR}";
	rm -rf -- "${TMP1}";


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
