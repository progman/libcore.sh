#!/bin/bash

while read -r NAME;
do
	echo "lxc import ./${NAME}.tar*";
	lxc import ./${NAME}.tar*;
	if [ "${?}" != "0" ];
	then
		echo "ERROR";
		exit 1;
	fi
done

exit 0;


#lxc export super-test /backups/super-test.tar.gz --instance-only;                                                                               # export в архив
#lxc export super-test /backups/super-test.tar    --instance-only --compression=none; ls -1 super-test.tar | repack.sh --zstd;                   # export в архив

#lxc import /backups/super-test.tar.zst;
