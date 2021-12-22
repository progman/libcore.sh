#!/bin/bash


function log_pack_xz()
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

function log_pack_zst()
{
	echo "${1}";
	rm -rf "${1}.zst.tmp" &> /dev/null < /dev/null;
	zstd -C --ultra -22 --threads=0 -o "${1}.zst.tmp" "${1}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR: pack error";
		exit 1;
	fi
	mv "${i}.zst.tmp" "${1}.zst";
	rm -rf -- "${1}";
}


for i in $(find . -type f | grep '/[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]_[0-9][0-9]-[0-9][0-9]-[0-9][0-9]\.[0-9][0-9][0-9][0-9][0-9][0-9]\.log$');
do
	log_pack_zst "${i}";
done


for i in $(find . -type f | grep '\.log\.[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]$');
do
	log_pack_zst "${i}";
done


exit 0;
