#!/bin/bash

if [ "${1}" == "" ];
then
	echo "example: ${0} FILELIST";
	exit 1;
fi


TMP1=$(mktemp);
if [ "${?}" != "0" ];
then
	echo "[!]FATAL: can't make tmp file";
	exit 1;
fi


TMP2=$(mktemp);
if [ "${?}" != "0" ];
then
	echo "[!]FATAL: can't make tmp file";
	exit 1;
fi


while read -r LINE;
do
	if [ -f "${LINE}" ];
	then
		SIZE=$(stat --printf='%s' "${LINE}");
		echo "${SIZE} ${LINE}" >> "${TMP1}";
	fi

done < "${1}";


sort -n "${TMP1}" | sed -e 's/^[0-9]*\ //g' > "${TMP2}";
rm -rf "${TMP1}" &> /dev/null;


COUNT_ALL=$(wc -l "${TMP2}" | { read a b; echo ${a}; });
COUNT_CUR=1;


while read -r LINE;
do
	echo -n "[${COUNT_CUR}/${COUNT_ALL}] ";

	if [ ! -f "${LINE}" ];
	then
		echo "not found, skip";
		(( COUNT_CUR++ ));
		continue;
	fi


	repack.sh "${LINE}";
	(( COUNT_CUR++ ));

done < "${TMP2}";


rm -rf "${TMP2}" &> /dev/null;
