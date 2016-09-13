#!/bin/bash

#apt-get install tor

LOCAL_TMP=$(mktemp -d);
if [ "${?}" != "0" ];
then
	echo "ERROR: can not make dir";
	exit 1;
fi

google-chrome --proxy-server="socks5://127.0.0.1:9050" --incognito --user-data-dir="${LOCAL_TMP}";

rm -rf -- "${LOCAL_TMP}" &> /dev/null;

exit 0;
