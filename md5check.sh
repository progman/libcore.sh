#!/bin/sh

FILE_LIST="$(find ./ -type f | grep 'md5$')";
for i in ${FILE_LIST};
do
	echo "check ${i}";
	md5sum -c "${i}";
done
