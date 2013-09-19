#!/bin/bash

if [ "${1}" == "" ];
then
	echo "example: ${0} FILELIST";
	exit 1;
fi


TMP1=$(mktemp);
TMP2=$(mktemp);

while read -r LINE;
do
#	echo "${LINE}";

	if [ -f "${LINE}" ];
	then
#		echo "${LINE}";

		SIZE=$(stat --printf='%s' "${LINE}");

		echo "${SIZE} ${LINE}" >> "${TMP1}";
	fi

done < "${1}";


cat "${TMP1}" | sort -n | sed -e 's/^[0-9]*\ //g' > "${TMP2}";
rm -rf "${TMP1}" &> /dev/null;


COUNT_ALL=$(cat "${TMP2}" | wc -l);
COUNT_CUR=1;


while read -r LINE;
do
#	echo "${LINE}"

	echo -n "[${COUNT_CUR}/${COUNT_ALL}] ";
	repack.sh "${LINE}";
#	echo "${LINE}";
	(( COUNT_CUR++ ));

done < "${TMP2}";


rm -rf "${TMP2}" &> /dev/null;
