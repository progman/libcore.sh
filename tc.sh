#!/bin/bash

# echo "alias tc='. tc.sh'" >> ~/.bashrc

X=0;

while true;
do
	Y=$(printf "/tmp/%08u" ${X});

	if [ ! -e "${Y}" ];
	then
		if [ "${X}" == "0" ];
		then
			mkdir "${Y}";
			cd "${Y}";
		else
			(( X-- ));
			Y=$(printf "/tmp/%08u" ${X});
			cd "${Y}";
		fi

		break;
	fi

	(( X++ ));

done
