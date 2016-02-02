#!/bin/sh


TMP="$(mktemp 2> /dev/null)";
if [ "${?}" != "0" ];
then
	echo "can't make tmp file";
	exit 1;
fi


ls -1 > "${TMP}";


while read -r i;
do
	j=$(echo "${i}" | iconv -fcp1251);
#	echo "${i} -> ${j}";


	if [ "${1}" != "-f" ];
	then
		echo "\"${j}\"";
	else
		if [ "${i}" != "${j}" ];
		then
			echo "\"${j}\"";
			mv "${i}" "${j}";
		fi
	fi


done < "${TMP}";

rm "${TMP}" &> /dev/null;

exit 0;
