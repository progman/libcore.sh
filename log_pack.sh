#!/bin/bash


function log_pack()
{
	echo "${1}";
	xz -9ec -- "${1}" > "${1}.xz.tmp";
	if [ "${?}" != "0" ];
	then
		echo "ERROR: pack error";
		exit 1;
	fi
	mv "${i}.xz.tmp" "${1}.xz";
	rm -rf -- "${1}";
}


for i in $(find . -type f | grep '/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]\.log$');
do
	log_pack "${i}";
done


for i in $(find . -type f | grep '\.log\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$');
do
	log_pack "${i}";
done


exit 0;
