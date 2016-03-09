#!/bin/sh

if [ "${FLAG_GKRELLM_DOWN}" == "1" ];
then
	gkrellm --geometry +1852+128
else
	gkrellm --geometry +1852+191
fi
