#!/bin/bash


if [ "${1}" == "" ] || [ "${2}" == "" ];
then
	echo "example: ${0} INPUT_VIDEO_FILE OUTPUT_VIDEO_FILE";
	exit 1;
fi


#ffmpeg -i "${1}" -c:v libx264 -profile:v baseline -level 3.0 -pix_fmt yuv420p -c:a aac "${2}.mp4";
ffmpeg -i "${1}" -c:v libx264 -c:a aac -b:a 128k -movflags +faststart "${2}.mp4";
if [ "${?}" != "0" ];
then
	echo "ERROR";
	exit 1;
fi


exit 0;
