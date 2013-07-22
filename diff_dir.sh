#!/bin/bash

if [ ! -d "${1}" ] || [ ! -d "${2}" ];
then
	echo "example: ${0} DIR1 DIR2";
	exit 0;
fi


D1=$(mktemp);
D2=$(mktemp);

cur_pwd=${PWD};

cd "${cur_pwd}";
cd "${1}"
find ./ -type f | sort > "${D1}";

cd "${cur_pwd}";
cd "${2}"
find ./ -type f | sort > "${D2}";

cd "${cur_pwd}";

diff -u --minimal ${D1} ${D2};

rm -rf ${D1} &> /dev/null;
rm -rf ${D2} &> /dev/null;
