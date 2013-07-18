#!/bin/bash


if [ "${1}" == "" ] && [ "${2}" == "" ];
then
	echo "width filter";
	echo "example: echo -e \"1\n12\n123\" | ${0} [ MIN ] MAX";
	exit 1;
fi


if [ "${1}" != "" ] && [ "${2}" == "" ];
then
	MIN=0;
	MAX="${1}";
fi


if [ "${1}" != "" ] && [ "${2}" != "" ];
then
	MIN="${1}";
	MAX="${2}";
fi


if [ "${MIN}" -gt "${MAX}" ]; # INTEGER1 is greater than INTEGER2
then
	TMP="${MIN}";
	MIN="${MAX}";
	MAX="${TMP}";
fi


#echo "MIN: \"${MIN}\"";
#echo "MAX: \"${MAX}\"";

while read -r LINE;
do
#echo "LINE: \"${LINE}\"";
	WIDTH=$(echo -n "${LINE}" | wc -c);


	if [ "${MIN}" != "" ] && [ "${MAX}" != "" ];
	then
		if [ ${MIN} -gt ${WIDTH} ]; # INTEGER1 is greater than INTEGER2
		then
			continue;
		fi

		if [ ${MAX} -lt ${WIDTH} ]; # INTEGER1 is less than INTEGER2
		then
			continue;
		fi
	fi


	echo "${LINE}";
done

exit 0;
