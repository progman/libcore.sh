#!/bin/bash

# echo "alias tn='. tn.sh'" >> ~/.bashrc

X=0;

while true;
do
	Y=$(printf "/tmp/%08u" ${X});

	if [ ! -e "${Y}" ];
	then
		mkdir "${Y}";
		cd "${Y}";

		break;
	fi

	(( X++ ));

done
