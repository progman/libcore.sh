#!/bin/bash

for i in $(find . -type f | grep '/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]\.log$');
do

	echo "${i}";
	xz -9ec -- "${i}" > "${i}.xz.tmp";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: pack error";
		exit 1;
	fi
	mv "${i}.xz.tmp"; "${i}.xz";
	rm -rf -- "${i}";

done


exit 0;
