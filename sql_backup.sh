#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.6
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view current time
function get_time()
{
	if [ "$(which date)" != "" ];
	then
		echo "[$(date +'%Y-%m-%d %H:%M:%S')]: ";
	fi
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(which ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# keep N new files and kill other
function kill_ring()
{
	local MAX_ITEM_COUNT="${1}";
	(( MAX_ITEM_COUNT+=0 ))


	if [ "${MAX_ITEM_COUNT}" == "0" ]; # 0 is disable
	then
		return;
	fi


	local FILENAME;
	find ./ -maxdepth 1 -type f -iname '*\.sql\.*' -printf '%T@ %p\n' | sort -nr | sed -e 's/^[0-9]*\.[0-9]*\ \.\///g' |
	{
		while read -r FILENAME;
		do

			if [ "${MAX_ITEM_COUNT}" == "0" ];
			then
				echo "rm -rf \"${FILENAME}\"";
				rm -rf -- "${FILENAME}" &> /dev/null;
				continue;
			fi

			(( MAX_ITEM_COUNT-- ));

		done
	};
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# pack name
function pack_name()
{
	local FILENAME="${1}";
	local FLAG_DISABLE_XZ="${2}";
	local FLAG_DISABLE_BZIP2="${3}";
	local FLAG_DISABLE_GZIP="${4}";

# select compressor
	local FLAG_COMPRESSOR_SELECT=0;
	local COMPRESSOR="tar";

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which xz)" != "" ] && [ "${FLAG_DISABLE_XZ}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.xz";
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which bzip2)" != "" ] && [ "${FLAG_DISABLE_BZIP2}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.bz2";
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which gzip)" != "" ] && [ "${FLAG_DISABLE_GZIP}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.gz";
	fi

	echo "${FILENAME}.${COMPRESSOR}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# compress dump
function pack()
{
	local FILENAME="${1}";
	local FLAG_DISABLE_XZ="${2}";
	local FLAG_DISABLE_BZIP2="${3}";
	local FLAG_DISABLE_GZIP="${4}";

# select compressor
	local FLAG_COMPRESSOR_SELECT=0;
	local COMPRESSOR="tar";
	local COMPRESSOR_OPT="cf";

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which xz)" != "" ] && [ "${FLAG_DISABLE_XZ}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.xz";
		COMPRESSOR_OPT="cfJ";

		if [ "${XZ_OPT}" == "" ];
		then
#			export XZ_OPT='-9 --extreme';
			export XZ_OPT='--lzma2=preset=9e,dict=1024MiB --memlimit-compress=7GiB';
		fi
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which bzip2)" != "" ] && [ "${FLAG_DISABLE_BZIP2}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.bz2";
		COMPRESSOR_OPT="cfj";

		if [ "${BZIP2}" == "" ];
		then
			export BZIP2='-9';
		fi
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which gzip)" != "" ] && [ "${FLAG_DISABLE_GZIP}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.gz";
		COMPRESSOR_OPT="cfz";

		if [ "${GZIP}" == "" ];
		then
			export GZIP='-9';
		fi
	fi

	TARGETNAME="${FILENAME}.${COMPRESSOR}"
	rm -rf -- "${TARGETNAME}.tmp";

	ionice -c 3 nice -n 20 tar "${COMPRESSOR_OPT}" "${TARGETNAME}.tmp" "${FILENAME}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf "${TARGETNAME}.tmp" &> /dev/null;
		echo " ERROR pack";
	else
		mv "${TARGETNAME}.tmp" "${TARGETNAME}";
	fi

	rm -rf -- "${FILENAME}";
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check minimal depends tools
	check_prog "date echo find ionice mkdir mv nice rm sed sort tar touch";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check env variables
	if [ "${SQL_DUMP_DIR}" == "" ];
	then
		echo "FATAL: var \"SQL_DUMP_DIR\" is not set";
		return 1;
	fi

	if [ "${SQL_DUMP_MAX_COUNT}" == "" ];
	then
		echo "FATAL: var \"SQL_DUMP_MAX_COUNT\" is not set";
		return 1;
	fi

	if [ "${SQL_SERVER}" == "" ];
	then
		echo "FATAL: var \"SQL_SERVER\" is not set";
		return 1;
	fi

	if [ "${SQL_HOST}" == "" ];
	then
		echo "FATAL: var \"SQL_HOST\" is not set";
		return 1;
	fi

	if [ "${SQL_PORT}" == "" ];
	then
		echo "FATAL: var \"SQL_PORT\" is not set";
		return 1;
	fi

	if [ "${SQL_DATABASE}" == "" ];
	then
		echo "FATAL: var \"SQL_DATABASE\" is not set";
		return 1;
	fi

	if [ "${SQL_LOGIN}" == "" ];
	then
		echo "FATAL: var \"SQL_LOGIN\" is not set";
		return 1;
	fi

	if [ "${SQL_PASSWORD}" == "" ];
	then
		echo "FATAL: var \"SQL_PASSWORD\" is not set";
		return 1;
	fi


# check sql server
	if [ "${SQL_SERVER}" != "postgresql" ] && [ "${SQL_SERVER}" != "mysql" ];
	then
		echo "FATAL: var \"SQL_SERVER\" must be set is \"postgresql\" or \"mysql\"";
		return 1;
	fi


# go to backup dir
	mkdir -p "${SQL_DUMP_DIR}";
	if [ ! -d "${SQL_DUMP_DIR}" ];
	then
		echo "FATAL: dir \"SQL_DUMP_DIR\" not found...";
		return 1;
	fi
	echo "$(get_time)use backup dir \"${SQL_DUMP_DIR}\"";
	touch "${SQL_DUMP_DIR}" &> /dev/null;
	cd "${SQL_DUMP_DIR}";


# get current time
	export TIMESTAMP=$(date +'%Y%m%d_%H%M%S');


	if [ "${SQL_SERVER}" == "postgresql" ];
	then

# check pg_dump
		if [ "$(which pg_dump)" == "" ];
		then
			echo "FATAL: you must install \"pg_dump\"...";
			return 1;
		fi


# set password
		PGPASSWORD="${SQL_PASSWORD}";
		export PGPASSWORD;


# create template dump
		mkdir "${SQL_SERVER}_template" &> /dev/null;
		cd "${SQL_SERVER}_template";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_template-${TIMESTAMP}.sql";
		PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${PACK_NAME}\"";
		pg_dump --exclude-schema="not_backup" -s -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;


# create dump
		mkdir "${SQL_SERVER}_dump" &> /dev/null;
		cd "${SQL_SERVER}_dump";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_dump-${TIMESTAMP}.sql";
		PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${PACK_NAME}\"";
		pg_dump --exclude-schema="not_backup" -b -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;


# create clear dump
		mkdir "${SQL_SERVER}_cdump" &> /dev/null;
		cd "${SQL_SERVER}_cdump";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_cdump-${TIMESTAMP}.sql";
		PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${PACK_NAME}\"";
		pg_dump --exclude-schema="not_backup" -b -C -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;
	fi


	if [ "${SQL_SERVER}" == "mysql" ];
	then

# check mysqldump
		if [ "$(which mysqldump)" == "" ];
		then
			echo "FATAL: you must install \"mysqldump\"...";
			return 1;
		fi


# create dump
		mkdir "${SQL_SERVER}_dump" &> /dev/null;
		cd "${SQL_SERVER}_dump";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_dump-${TIMESTAMP}.sql";
		PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${PACK_NAME}\"";
		OPTIONS='--default-character-set=utf8 --single-transaction --compatible=postgresql -t --compact --skip-opt --compact';
#		OPTIONS='--ignore-table=xxxxxx';
#		TABLES='xxxxxxxxxx';
		TABLES='';

		export MYSQL_PWD="${SQL_PASSWORD}";
		mysqldump ${OPTIONS} --host="${SQL_HOST}" --port="${SQL_PORT}" --user="${SQL_LOGIN}" "${SQL_DATABASE}" ${TABLES} > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
