#!/bin/bash

FLAG_OK=1;

while true;
do
	if [ ! -e /etc/resolv.conf ];
	then
		FLAG_OK=0;
		break;
	fi


	if [ "$(cat /etc/resolv.conf | grep '8.8.8.8' | wc -l)" == "0" ];
	then
		FLAG_OK=0;
		break;
	fi


	if [ "$(cat /etc/resolv.conf | grep '1.1.1.1' | wc -l)" == "0" ];
	then
		FLAG_OK=0;
		break;
	fi


	break;
done


if [ ${FLAG_OK} -eq 1 ];
then
	echo "ok";
	exit 0;
fi


echo "remake";
echo -n > /etc/resolv.conf;
echo 'nameserver 1.1.1.1' >> /etc/resolv.conf;
echo 'nameserver 8.8.8.8' >> /etc/resolv.conf;


exit 0;
