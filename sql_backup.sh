#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.1.3
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# view current time
function get_time()
{
	if [ "$(command -v date)" != "" ];
	then
		echo "[$(date +'%Y-%m-%d %H:%M:%S')]: ";
	fi
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check depends
function check_prog()
{
	for i in ${1};
	do
		if [ "$(command -v ${i})" == "" ];
		then
			echo "FATAL: you must install \"${i}\"...";
			return 1;
		fi
	done

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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
				echo "$(get_time)rm -rf \"${FILENAME}\"";
				rm -rf -- "${FILENAME}" &> /dev/null;
				continue;
			fi

			(( MAX_ITEM_COUNT-- ));

		done
	};
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v xz)" != "" ] && [ "${FLAG_DISABLE_XZ}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.xz";
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v bzip2)" != "" ] && [ "${FLAG_DISABLE_BZIP2}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.bz2";
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v gzip)" != "" ] && [ "${FLAG_DISABLE_GZIP}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.gz";
	fi

	echo "${FILENAME}.${COMPRESSOR}";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
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

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v xz)" != "" ] && [ "${FLAG_DISABLE_XZ}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.xz";
		COMPRESSOR_OPT="cfJ";

		if [ "${XZ_OPT}" == "" ];
		then
#			export XZ_OPT='-9 --extreme';
#			export XZ_OPT='--lzma2=preset=9e,dict=1024MiB --memlimit-compress=7GiB';
			export XZ_OPT='--lzma2=preset=9e';
		fi
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v bzip2)" != "" ] && [ "${FLAG_DISABLE_BZIP2}" != "1" ];
	then
		FLAG_COMPRESSOR_SELECT=1;
		COMPRESSOR="tar.bz2";
		COMPRESSOR_OPT="cfj";

		if [ "${BZIP2}" == "" ];
		then
			export BZIP2='-9';
		fi
	fi

	if [ "${FLAG_COMPRESSOR_SELECT}" == "0" ] && [ "$(command -v gzip)" != "" ] && [ "${FLAG_DISABLE_GZIP}" != "1" ];
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
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# check var list
function var_check()
{
	if [ "${SQL_TYPE}" == "" ];
	then
		echo "FATAL: var \"SQL_TYPE\" is not set";
		return 1;
	fi

	if [ "${SQL_TYPE}" != "postgres" ] && [ "${SQL_TYPE}" != "mysql" ];
	then
		echo "FATAL: var \"SQL_TYPE\" is not \"postgres\" or \"mysql\"";
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

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres_global()
{
# check pg_dumpall
	if [ "$(command -v pg_dumpall)" == "" ];
	then
		echo "FATAL: you must install \"pg_dumpall\"...";
		return 1;
	fi


# set password
	PGPASSWORD="${SQL_PASSWORD}";
	export PGPASSWORD;


	FILENAME="${SQL_DATABASE}_${SQL_TYPE}-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${PACK_NAME}\"";


	local CMD="";
	if [ "${SQL_CONTAINER}" != "" ];
	then
		CMD+="docker exec -it ${SQL_CONTAINER} ";
	fi
	CMD+="pg_dumpall";
	CMD+=" -g";
	CMD+=" -c";
	CMD+=" --if-exists";
	CMD+=" --host=${SQL_HOST}";
	CMD+=" --port=${SQL_PORT}";
	CMD+=" --username=${SQL_LOGIN}";

	if [ "${FLAG_DEBUG}" == "1" ];
	then
		echo "$(get_time)${CMD}";
	fi
	${CMD} > "${FILENAME}.tmp" 2> /dev/null;
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


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres_case1()
{
	local STATUS;
	local OPT;


#  --lock-wait-timeout=ТАЙМ-АУТ прервать операцию при тайм-ауте блокировки таблицы
#  -n, --schema=ШАБЛОН          выгрузить только указанную схему(ы)
#  -S, --superuser=ИМЯ          имя пользователя, который будет задействован при восстановлении из текстового формата
#  -t, --table=ШАБЛОН           выгрузить только указанную таблицу(ы)
#  -T, --exclude-table=ШАБЛОН   НЕ выгружать указанную таблицу(ы)
#  --column-inserts             выгружать данные в виде INSERT с именами столбцов
#  --disable-dollar-quoting     отключить спецстроки с $, выводить строки по стандарту SQL
#  --exclude-table-data=ШАБЛОН  НЕ выгружать данные указанной таблицы (таблиц)
#  --extra-float-digits=ЧИСЛО   переопределить значение extra_float_digits
#  --inserts                    выгрузить данные в виде команд INSERT, не COPY
#  --load-via-partition-root    загружать секции через главную таблицу
#  --on-conflict-do-nothing     добавлять ON CONFLICT DO NOTHING в команды INSERT
#  --quote-all-identifiers      заключать в кавычки все идентификаторы, а не только ключевые слова
#  --rows-per-insert=ЧИСЛО      число строк в одном INSERT; подразумевает --inserts
#  --section=РАЗДЕЛ             выгрузить заданный раздел (pre-data, data или post-data)
#  --snapshot=СНИМОК            использовать при выгрузке заданный снимок
#  --strict-names               требовать, чтобы при указании шаблона включения таблицы и/или схемы ему соответствовал минимум один объект
#  --use-set-session-authorization устанавливать владельца, используя команды SET SESSION AUTHORIZATION вместо ALTER OWNER
#  --role=ИМЯ_РОЛИ          выполнить SET ROLE перед выгрузкой


# create template dump
	mkdir "${SQL_TYPE}_template" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_template";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_template-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";


	local CMD="";
	if [ "${SQL_CONTAINER}" != "" ];
	then
		CMD+="docker exec -it ${SQL_CONTAINER} ";
	fi
	CMD+="pg_dump";
	CMD+=" --schema-only";               # выгрузить только схему, без данных
#	CMD+=" --jobs=2";                    # распараллелить копирование на указанное число заданий
	CMD+=" --exclude-schema=not_backup"; # НЕ выгружать указанную схему(ы)
	CMD+=" --clean";                     # очистить (удалить) объекты БД при восстановлении
	CMD+=" --if-exists";                 # применять IF EXISTS при удалении объектов
	CMD+=" --compress=0";                # уровень сжатия при архивации
	CMD+=" --format=p";                  # формат выводимых данных: текстовый (по умолчанию))
	CMD+=" --serializable-deferrable";   # дождаться момента для выгрузки данных без аномалий
	CMD+=" --host=${SQL_HOST}";          # имя сервера баз данных или каталог сокетов
	CMD+=" --port=${SQL_PORT}";          # номер порта сервера БД
	CMD+=" --username=${SQL_LOGIN}";     # имя пользователя баз данных
	CMD+=" ${SQL_DATABASE}";             # имя базы данных для выгрузки

	if [ "${FLAG_DEBUG}" == "1" ];
	then
		echo "$(get_time)${CMD}";
	fi
	${CMD} > "${FILENAME}.tmp" 2> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${FILENAME}.tmp";
		echo "ERROR: unknown error1";
		return 1;
	fi
	mv "${FILENAME}.tmp" "${FILENAME}";

	pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
	kill_ring "${SQL_DUMP_MAX_COUNT}";
	cd ..;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres_case2()
{
	local STATUS;
	local OPT;


#  --lock-wait-timeout=ТАЙМ-АУТ прервать операцию при тайм-ауте блокировки таблицы
#  -n, --schema=ШАБЛОН          выгрузить только указанную схему(ы)
#  -S, --superuser=ИМЯ          имя пользователя, который будет задействован при восстановлении из текстового формата
#  -t, --table=ШАБЛОН           выгрузить только указанную таблицу(ы)
#  -T, --exclude-table=ШАБЛОН   НЕ выгружать указанную таблицу(ы)
#  --column-inserts             выгружать данные в виде INSERT с именами столбцов
#  --disable-dollar-quoting     отключить спецстроки с $, выводить строки по стандарту SQL
#  --exclude-table-data=ШАБЛОН  НЕ выгружать данные указанной таблицы (таблиц)
#  --extra-float-digits=ЧИСЛО   переопределить значение extra_float_digits
#  --inserts                    выгрузить данные в виде команд INSERT, не COPY
#  --load-via-partition-root    загружать секции через главную таблицу
#  --on-conflict-do-nothing     добавлять ON CONFLICT DO NOTHING в команды INSERT
#  --quote-all-identifiers      заключать в кавычки все идентификаторы, а не только ключевые слова
#  --rows-per-insert=ЧИСЛО      число строк в одном INSERT; подразумевает --inserts
#  --section=РАЗДЕЛ             выгрузить заданный раздел (pre-data, data или post-data)
#  --snapshot=СНИМОК            использовать при выгрузке заданный снимок
#  --strict-names               требовать, чтобы при указании шаблона включения таблицы и/или схемы ему соответствовал минимум один объект
#  --use-set-session-authorization устанавливать владельца, используя команды SET SESSION AUTHORIZATION вместо ALTER OWNER
#  --role=ИМЯ_РОЛИ          выполнить SET ROLE перед выгрузкой


# create dump
	mkdir "${SQL_TYPE}_dump" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_dump";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_dump-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";


	local CMD="";
	if [ "${SQL_CONTAINER}" != "" ];
	then
		CMD+="docker exec -it ${SQL_CONTAINER} ";
	fi
	CMD+="pg_dump";
	CMD+=" --blobs";                     # выгрузить также большие объекты
#	CMD+=" --jobs=2";                    # распараллелить копирование на указанное число заданий
	CMD+=" --exclude-schema=not_backup"; # НЕ выгружать указанную схему(ы)
	CMD+=" --clean";                     # очистить (удалить) объекты БД при восстановлении
	CMD+=" --if-exists";                 # применять IF EXISTS при удалении объектов
	CMD+=" --compress=0";                # уровень сжатия при архивации
	CMD+=" --format=p";                  # формат выводимых данных: текстовый (по умолчанию))
	CMD+=" --serializable-deferrable";   # дождаться момента для выгрузки данных без аномалий
	CMD+=" --host=${SQL_HOST}";          # имя сервера баз данных или каталог сокетов
	CMD+=" --port=${SQL_PORT}";          # номер порта сервера БД
	CMD+=" --username=${SQL_LOGIN}";     # имя пользователя баз данных
	CMD+=" ${SQL_DATABASE}";             # имя базы данных для выгрузки

	if [ "${FLAG_DEBUG}" == "1" ];
	then
		echo "$(get_time)${CMD}";
	fi
	${CMD} > "${FILENAME}.tmp" 2> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${FILENAME}.tmp";
		echo "ERROR: unknown error2";
		return 1;
	fi
	mv "${FILENAME}.tmp" "${FILENAME}";

	pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
	kill_ring "${SQL_DUMP_MAX_COUNT}";
	cd ..;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres_case3()
{
	local STATUS;
	local OPT;


#  --lock-wait-timeout=ТАЙМ-АУТ прервать операцию при тайм-ауте блокировки таблицы
#  -n, --schema=ШАБЛОН          выгрузить только указанную схему(ы)
#  -S, --superuser=ИМЯ          имя пользователя, который будет задействован при восстановлении из текстового формата
#  -t, --table=ШАБЛОН           выгрузить только указанную таблицу(ы)
#  -T, --exclude-table=ШАБЛОН   НЕ выгружать указанную таблицу(ы)
#  --column-inserts             выгружать данные в виде INSERT с именами столбцов
#  --disable-dollar-quoting     отключить спецстроки с $, выводить строки по стандарту SQL
#  --exclude-table-data=ШАБЛОН  НЕ выгружать данные указанной таблицы (таблиц)
#  --extra-float-digits=ЧИСЛО   переопределить значение extra_float_digits
#  --inserts                    выгрузить данные в виде команд INSERT, не COPY
#  --load-via-partition-root    загружать секции через главную таблицу
#  --on-conflict-do-nothing     добавлять ON CONFLICT DO NOTHING в команды INSERT
#  --quote-all-identifiers      заключать в кавычки все идентификаторы, а не только ключевые слова
#  --rows-per-insert=ЧИСЛО      число строк в одном INSERT; подразумевает --inserts
#  --section=РАЗДЕЛ             выгрузить заданный раздел (pre-data, data или post-data)
#  --snapshot=СНИМОК            использовать при выгрузке заданный снимок
#  --strict-names               требовать, чтобы при указании шаблона включения таблицы и/или схемы ему соответствовал минимум один объект
#  --use-set-session-authorization устанавливать владельца, используя команды SET SESSION AUTHORIZATION вместо ALTER OWNER
#  --role=ИМЯ_РОЛИ          выполнить SET ROLE перед выгрузкой


# create clear dump
	mkdir "${SQL_TYPE}_cdump" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_cdump";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_cdump-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";


	local CMD="";
	if [ "${SQL_CONTAINER}" != "" ];
	then
		CMD+="docker exec -it ${SQL_CONTAINER} ";
	fi
	CMD+="pg_dump";
	CMD+=" --create";                    # добавить в копию команды создания базы данных
	CMD+=" --inserts";                   # выгрузить данные в виде команд INSERT, не COPY
	CMD+=" --blobs";                     # выгрузить также большие объекты
#	CMD+=" --jobs=2";                    # распараллелить копирование на указанное число заданий
	CMD+=" --exclude-schema=not_backup"; # НЕ выгружать указанную схему(ы)
	CMD+=" --clean";                     # очистить (удалить) объекты БД при восстановлении
	CMD+=" --if-exists";                 # применять IF EXISTS при удалении объектов
	CMD+=" --compress=0";                # уровень сжатия при архивации
	CMD+=" --format=p";                  # формат выводимых данных: текстовый (по умолчанию))
	CMD+=" --serializable-deferrable";   # дождаться момента для выгрузки данных без аномалий
	CMD+=" --host=${SQL_HOST}";          # имя сервера баз данных или каталог сокетов
	CMD+=" --port=${SQL_PORT}";          # номер порта сервера БД
	CMD+=" --username=${SQL_LOGIN}";     # имя пользователя баз данных
	CMD+=" ${SQL_DATABASE}";             # имя базы данных для выгрузки

	if [ "${FLAG_DEBUG}" == "1" ];
	then
		echo "$(get_time)${CMD}";
	fi
	${CMD} > "${FILENAME}.tmp" 2> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${FILENAME}.tmp";
		echo "ERROR: unknown error3";
		return 1;
	fi
	mv "${FILENAME}.tmp" "${FILENAME}";

	pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
	kill_ring "${SQL_DUMP_MAX_COUNT}";
	cd ..;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres_case4()
{
	local STATUS;
	local OPT;


#  --lock-wait-timeout=ТАЙМ-АУТ прервать операцию при тайм-ауте блокировки таблицы
#  -n, --schema=ШАБЛОН          выгрузить только указанную схему(ы)
#  -S, --superuser=ИМЯ          имя пользователя, который будет задействован при восстановлении из текстового формата
#  -t, --table=ШАБЛОН           выгрузить только указанную таблицу(ы)
#  -T, --exclude-table=ШАБЛОН   НЕ выгружать указанную таблицу(ы)
#  --column-inserts             выгружать данные в виде INSERT с именами столбцов
#  --disable-dollar-quoting     отключить спецстроки с $, выводить строки по стандарту SQL
#  --exclude-table-data=ШАБЛОН  НЕ выгружать данные указанной таблицы (таблиц)
#  --extra-float-digits=ЧИСЛО   переопределить значение extra_float_digits
#  --inserts                    выгрузить данные в виде команд INSERT, не COPY
#  --load-via-partition-root    загружать секции через главную таблицу
#  --on-conflict-do-nothing     добавлять ON CONFLICT DO NOTHING в команды INSERT
#  --quote-all-identifiers      заключать в кавычки все идентификаторы, а не только ключевые слова
#  --rows-per-insert=ЧИСЛО      число строк в одном INSERT; подразумевает --inserts
#  --section=РАЗДЕЛ             выгрузить заданный раздел (pre-data, data или post-data)
#  --snapshot=СНИМОК            использовать при выгрузке заданный снимок
#  --strict-names               требовать, чтобы при указании шаблона включения таблицы и/или схемы ему соответствовал минимум один объект
#  --use-set-session-authorization устанавливать владельца, используя команды SET SESSION AUTHORIZATION вместо ALTER OWNER
#  --role=ИМЯ_РОЛИ          выполнить SET ROLE перед выгрузкой


# create xdump
	mkdir "${SQL_TYPE}_xdump" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_xdump";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_dump-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";


	local CMD="";
	if [ "${SQL_CONTAINER}" != "" ];
	then
		CMD+="docker exec -it ${SQL_CONTAINER} ";
	fi
	CMD+="pg_dump";
	CMD+=" --no-owner";                  # не восстанавливать владение объектами
	CMD+=" --no-privileges";             # не выгружать права (назначение/отзыв)
	CMD+=" --blobs";                     # выгрузить также большие объекты
#	CMD+=" --jobs=2";                    # распараллелить копирование на указанное число заданий
	CMD+=" --exclude-schema=not_backup"; # НЕ выгружать указанную схему(ы)
	CMD+=" --clean";                     # очистить (удалить) объекты БД при восстановлении
	CMD+=" --if-exists";                 # применять IF EXISTS при удалении объектов
	CMD+=" --compress=0";                # уровень сжатия при архивации
	CMD+=" --format=p";                  # формат выводимых данных: текстовый (по умолчанию))
	CMD+=" --serializable-deferrable";   # дождаться момента для выгрузки данных без аномалий
	CMD+=" --host=${SQL_HOST}";          # имя сервера баз данных или каталог сокетов
	CMD+=" --port=${SQL_PORT}";          # номер порта сервера БД
	CMD+=" --username=${SQL_LOGIN}";     # имя пользователя баз данных
	CMD+=" ${SQL_DATABASE}";             # имя базы данных для выгрузки

	if [ "${FLAG_DEBUG}" == "1" ];
	then
		echo "$(get_time)${CMD}";
	fi
	${CMD} > "${FILENAME}.tmp" 2> /dev/null;
	if [ "${?}" != "0" ];
	then
		rm -rf -- "${FILENAME}.tmp";
		echo "ERROR: unknown error4";
		return 1;
	fi
	mv "${FILENAME}.tmp" "${FILENAME}";

	pack ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}";
	kill_ring "${SQL_DUMP_MAX_COUNT}";
	cd ..;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_postgres()
{
	local STATUS;
	local OPT;


	if [ "${SQL_LOGIN}" == "postgres" ] && [ "${SQL_DATABASE}" == "postgres" ];
	then
		backup_postgres_global;
		STATUS="${?}";
		return "${STATUS}";
	fi


# check pg_dump
	if [ "$(command -v pg_dump)" == "" ];
	then
		echo "FATAL: you must install \"pg_dump\"...";
		return 1;
	fi


# set password
	PGPASSWORD="${SQL_PASSWORD}";
	export PGPASSWORD;


# select case
	if [ "${FLAG_CASE1}" == "1" ] || [ "${FLAG_CASE_DEFAULT}" == "1" ];
	then
		backup_postgres_case1;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	if [ "${FLAG_CASE2}" == "1" ];
	then
		backup_postgres_case2;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	if [ "${FLAG_CASE3}" == "1" ] || [ "${FLAG_CASE_DEFAULT}" == "1" ];
	then
		backup_postgres_case3;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	if [ "${FLAG_CASE4}" == "1" ];
	then
		backup_postgres_case4;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_mysql_case1()
{
# create dump
	mkdir "${SQL_TYPE}_dump" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_dump";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_dump-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";
#	OPTIONS='--default-character-set=utf8 --single-transaction --compatible=postgresql -t --compact --skip-opt';
	OPTIONS='--default-character-set=utf8 --single-transaction --compatible=ansi       -t --compact --skip-opt';
#	OPTIONS='--ignore-table=xxxxxx';
#	TABLES='xxxxxxxxxx';
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
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_mysql_case2()
{
# create clear dump
	mkdir "${SQL_TYPE}_cdump" &> /dev/null;
	CUR_DIR="${SQL_TYPE}_cdump";
	cd "${CUR_DIR}";

	FILENAME="${SQL_DATABASE}_${SQL_TYPE}_dump-${TIMESTAMP}.sql";
	PACK_NAME=$(pack_name ${FILENAME} "${SQL_BACKUP_FLAG_DISABLE_XZ}" "${SQL_BACKUP_FLAG_DISABLE_BZIP2}" "${SQL_BACKUP_FLAG_DISABLE_GZIP}");
	echo "$(get_time)make \"${SQL_DUMP_DIR}/${CUR_DIR}/${PACK_NAME}\"";
#	OPTIONS='--default-character-set=utf8 --single-transaction --compatible=postgresql --opt';
	OPTIONS='--default-character-set=utf8 --single-transaction --compatible=ansi       --opt';
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
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function backup_mysql()
{
# check mysqldump
	if [ "$(command -v mysqldump)" == "" ];
	then
		echo "FATAL: you must install \"mysqldump\"...";
		return 1;
	fi


# select case
	if [ "${FLAG_CASE1}" == "1" ] || [ "${FLAG_CASE_DEFAULT}" == "1" ];
	then
		backup_mysql_case1;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	if [ "${FLAG_CASE2}" == "1" ] || [ "${FLAG_CASE_DEFAULT}" == "1" ];
	then
		backup_mysql_case2;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check minimal depends tools
	check_prog "date echo find ionice mkdir mv nice rm sed sort tar touch";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	if  [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} ENV_FILE";
		return 0;
	fi


	if [ "${1}" != "" ] && [ -e "${1}" ];
	then
		source "${1}";
		export SQL_DUMP_DIR="${SQL_DUMP_DIR}";
		export SQL_DUMP_MAX_COUNT="${SQL_DUMP_MAX_COUNT}";
		export SQL_TYPE="${SQL_TYPE}";
		export SQL_HOST="${SQL_HOST}";
		export SQL_PORT="${SQL_PORT}";
		export SQL_DATABASE="${SQL_DATABASE}";
		export SQL_LOGIN="${SQL_LOGIN}";
		export SQL_PASSWORD="${SQL_PASSWORD}";
	fi


	FLAG_CASE_DEFAULT='1';
	FLAG_CASE1='0';
	FLAG_CASE2='0';
	FLAG_CASE3='0';
	FLAG_CASE4='0';
	FLAG_CASE5='0';
	FLAG_CASE6='0';
	FLAG_CASE7='0';
	FLAG_CASE8='0';
	FLAG_CASE9='0';


	local ARG_COUNT="${#}";
	while true;
	do
		if [ "${1}" == "--case1" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE1='1';
		fi

		if [ "${1}" == "--case2" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE2='1';
		fi

		if [ "${1}" == "--case3" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE3='1';
		fi

		if [ "${1}" == "--case4" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE4='1';
		fi

		if [ "${1}" == "--case5" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE5='1';
		fi

		if [ "${1}" == "--case6" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE6='1';
		fi

		if [ "${1}" == "--case7" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE7='1';
		fi

		if [ "${1}" == "--case8" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE8='1';
		fi

		if [ "${1}" == "--case9" ];
		then
			FLAG_CASE_DEFAULT='0';
			FLAG_CASE9='1';
		fi

		(( ARG_COUNT-- ));
		shift 1;

		if [ "${ARG_COUNT}" == "0" ];
		then
			break;
		fi
	done


# check env variables
	var_check;
	if [ "${?}" != "0" ];
	then
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


	if [ "${SQL_TYPE}" == "postgres" ];
	then
		backup_postgres;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	if [ "${SQL_TYPE}" == "mysql" ];
	then
		backup_mysql;
		if [ "${?}" != "0" ];
		then
			return 1;
		fi
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
