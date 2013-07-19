#!/bin/sh

# (c) progman http://www.gnuplanet.ru
# script using imagemagick

if [ "${1}" == "" ];
then
    echo "image-autocontrast version 0.0.3"
    echo "example: ${0} /tmp/image-dir/"
    exit 0
fi

cd "${1}"
if [ "${?}" == "0" ];
then

    for file in *;
    do

	if [ "$(echo ${file} | grep -i 'png$\|jpg$\|jpeg$\|gif$\|bmp$\|pcx$' | wc -l)" != "0" ];
	then

	    echo "convert \"${file}\"";
	    convert -normalize "${file}" "${file}-autocontrast.jpg";

	fi

    done
fi
