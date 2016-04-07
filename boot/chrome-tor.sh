#!/bin/bash

#apt-get install tor

TMP="${HOME}/.config/google-chrome-tor";
mkdir -m 0700 ~/.config &> /dev/null;
if [ "${?}" != "0" ];
then
	echo "ERROR: can not make dir";
	exit 1;
fi
rm -rf -- "${TMP}" &> /dev/null;
mkdir -p -- "${TMP}" &> /dev/null;
if [ "${?}" != "0" ];
then
	echo "ERROR: can not make dir";
	exit 1;
fi
google-chrome --proxy-server="socks5://127.0.0.1:9050" --incognito --user-data-dir="${TMP}";
rm -rf -- "${TMP}" &> /dev/null;

exit 0;
