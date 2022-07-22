#!/bin/bash

# https://stackoverflow.com/questions/58742765/convert-videos-from-264-to-265-hevc-with-ffmpeg

SOURCE="${1}";
TARGET="${2}";

if [ "${SOURCE}" == "" ] || [ "${TARGET}" == "" ];
then
	echo "example: ${0} SOURCE TARGET";
	exit 0;
fi


FLAG_NVIDIA=$(lspci | grep -i vga | grep -i NVIDIA | wc -l);
if [ "${FLAG_NVIDIA}" == "0" ];
then
	ffmpeg -i "${SOURCE}"                 -c:v libx265 -vtag hvc1 -c:a copy "${TARGET}";
else
	ffmpeg -i "${SOURCE}" -c:v hevc_nvenc -c:v libx265 -vtag hvc1 -c:a copy "${TARGET}";
fi


exit 0;
