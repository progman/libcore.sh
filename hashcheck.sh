#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.4
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(command -v ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo find grep md5sum shasum sha3sum";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	FILE_LIST="$(find ./ -type f | grep '\.md5$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check md5   : ";
		md5sum -c "${i}";
	done

	FILE_LIST="$(find ./ -type f | grep '\.md5sum$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check md5   : ";
		md5sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha1$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha1  : ";
		shasum -a 1 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha224$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha224: ";
		shasum -a 224 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha256$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha256: ";
		shasum -a 256 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha384$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha384: ";
		shasum -a 384 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha512$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha512: ";
		shasum -a 512 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3: ";
		sha3sum -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_224$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_224: ";
		sha3sum -a 224 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_256$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_256: ";
		sha3sum -a 256 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_384$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_384: ";
		sha3sum -a 384 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_512$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_512: ";
		sha3sum -a 512 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_128000$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_128000: ";
		sha3sum -a 128000 -c "${i}";
	done


	FILE_LIST="$(find ./ -type f | grep '\.sha3_256000$')";
	for i in ${FILE_LIST};
	do
		echo -ne "check sha3_256000: ";
		sha3sum -a 256000 -c "${i}";
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
#TODO: file --mime *
