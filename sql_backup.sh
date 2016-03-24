#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.3
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
# compress dump
function compress()
{
	local COMPRESSOR="${1}";
	local FILENAME="${2}";


	if [ "${COMPRESSOR}" == "xz" ];
	then
		if [ "${XZ_OPT}" == "" ];
		then
#			export XZ_OPT='-9 --extreme';
			export XZ_OPT='--lzma2=preset=9e,dict=1024MiB --memlimit-compress=7GiB';
		fi

		TARGET="${FILENAME}.tar.${COMPRESSOR}";
#		ionice -c 3 nice -n 19 xz -zc "${FILENAME}" > "${TARGET}.tmp" 2> /dev/null < /dev/null;
		ionice -c 3 nice -n 19 tar cvfJ "${TARGET}.tmp" "${FILENAME}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " xz pack error";
			rm -rf -- "${TARGET}.tmp";
			return 1;
		fi
		mv -- "${TARGET}.tmp" "${TARGET}";
		rm -rf -- "${FILENAME}";
	fi


	if [ "${COMPRESSOR}" == "bz2" ];
	then
		if [ "${BZIP2}" == "" ];
		then
			export BZIP2='-9';
		fi

		TARGET="${FILENAME}.tar.${COMPRESSOR}";
#		ionice -c 3 nice -n 19 bzip2 -zc "${FILENAME}" > "${TARGET}.tmp" 2> /dev/null < /dev/null;
		ionice -c 3 nice -n 19 tar cvfj "${TARGET}.tmp" "${FILENAME}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " bzip2 pack error";
			rm -rf -- "${TARGET}.tmp";
			return 1;
		fi
		mv -- "${TARGET}.tmp" "${TARGET}";
		rm -rf -- "${FILENAME}";
	fi


	if [ "${COMPRESSOR}" == "gz" ];
	then
		if [ "${GZIP}" == "" ];
		then
			export GZIP='-9';
		fi

		TARGET="${FILENAME}.tar.${COMPRESSOR}";
#		ionice -c 3 nice -n 19 gzip -c "${FILENAME}" > "${TARGET}.tmp" 2> /dev/null < /dev/null;
		ionice -c 3 nice -n 19 tar cvfz "${TARGET}.tmp" "${FILENAME}" &> /dev/null < /dev/null;
		if [ "${?}" != "0" ];
		then
			echo " gzip pack error";
			rm -rf -- "${TARGET}.tmp";
			return 1;
		fi
		mv -- "${TARGET}.tmp" "${TARGET}";
		rm -rf -- "${FILENAME}";
	fi


	return 0;
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


# select compressor
	local COMPRESSOR;
	local FLAG_COMPRESSOR_SELECT=0;

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which xz)" != "" ];
	then
		COMPRESSOR="xz";
		FLAG_COMPRESSOR_SELECT=1;
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which bzip2)" != "" ];
	then
		COMPRESSOR="bz2";
		FLAG_COMPRESSOR_SELECT=1;
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(which gzip)" != "" ];
	then
		COMPRESSOR="gz";
		FLAG_COMPRESSOR_SELECT=1;
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ];
	then
		echo "FATAL: you must install \"xz\" or \"bzip2\" or \"gzip\"...";
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
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${SQL_SERVER}_template/${FILENAME}.tar.${COMPRESSOR}\"";
		pg_dump --exclude-schema="not_backup" -s -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		compress "${COMPRESSOR}" "${FILENAME}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;


# create dump
		mkdir "${SQL_SERVER}_dump" &> /dev/null;
		cd "${SQL_SERVER}_dump";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_dump-${TIMESTAMP}.sql";
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${SQL_SERVER}_dump/${FILENAME}.tar.${COMPRESSOR}\"";
		pg_dump --exclude-schema="not_backup" -b -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		compress "${COMPRESSOR}" "${FILENAME}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;


# create clear dump
		mkdir "${SQL_SERVER}_cdump" &> /dev/null;
		cd "${SQL_SERVER}_cdump";

		FILENAME="${SQL_DATABASE}_${SQL_SERVER}_cdump-${TIMESTAMP}.sql";
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${SQL_SERVER}_dump/${FILENAME}.tar.${COMPRESSOR}\"";
		pg_dump --exclude-schema="not_backup" -b -C -c --if-exists --compress=0 --format=p --serializable-deferrable --host="${SQL_HOST}" --port="${SQL_PORT}" --username="${SQL_LOGIN}" "${SQL_DATABASE}" > "${FILENAME}.tmp" 2> /dev/null;
		if [ "${?}" != "0" ];
		then
			rm -rf -- "${FILENAME}.tmp";
			echo "ERROR: unknown error";
			return 1;
		fi
		mv "${FILENAME}.tmp" "${FILENAME}";

		compress "${COMPRESSOR}" "${FILENAME}";
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
		echo "$(get_time)make \"${SQL_DUMP_DIR}/${SQL_SERVER}_dump/${FILENAME}.tar.${COMPRESSOR}\"";
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


		compress "${COMPRESSOR}" "${FILENAME}";
		kill_ring "${SQL_DUMP_MAX_COUNT}";
		cd ..;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
