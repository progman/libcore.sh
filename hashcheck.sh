#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
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
# check depends tools
	check_prog "echo find grep md5sum sha1sum sha224sum sha256sum sha384sum sha512sum";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	FILE_LIST="$(find ./ -type f | grep '\.md5$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		md5sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha1$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		sha1sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha224$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		sha224sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha256$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		sha256sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha384$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		sha384sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha512$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check ${i}\n\t";
		sha512sum -c "${i}";
	done


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
