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
	check_prog "echo grep wc convert";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if [ "${1}" == "" ] || [ ! -d "${1}" ];
	then
		echo "image-autocontrast version 0.0.3"
		echo "example: ${0} /tmp/image-dir/"
		return 0
	fi


	cd "${1}";

	for file in *;
	do
		if [ "$(echo ${file} | grep -i 'png$\|jpg$\|jpeg$\|gif$\|bmp$\|pcx$' | wc -l)" != "0" ];
		then
			echo "convert \"${file}\"";
			convert -normalize "${file}" "${file}-autocontrast.jpg";
		fi
	done


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
