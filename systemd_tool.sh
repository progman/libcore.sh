#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
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
function systemd_gc()
{
	journalctl --rotate;
	journalctl --vacuum-time=1s;
	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function systemd_log()
{
	if [ ! -e ./.env ];
	then
		echo "ERROR: you must make .env file";
		return 0;
	fi

	export $(cat .env);

	if [ "${SYSTEMD_SERVICE}" == "" ];
	then
		echo "ERROR: you must set SYSTEMD_SERVICE";
		return 1;
	fi

	journalctl -u ${SYSTEMD_SERVICE};

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function systemd_status()
{
	if [ ! -e ./.env ];
	then
		echo "ERROR: you must make .env file";
		return 0;
	fi

	export $(cat .env);

	if [ "${SYSTEMD_SERVICE}" == "" ];
	then
		echo "ERROR: you must set SYSTEMD_SERVICE";
		return 1;
	fi

	STATE="$(systemctl show ${SYSTEMD_SERVICE} | grep -- 'ActiveState=' | sed -e 's/.*=//g')";
	echo "state: ${STATE}";

	SUB_STATE="$(systemctl show ${SYSTEMD_SERVICE} | grep -- 'SubState=' | sed -e 's/.*=//g')";
	echo "sub_state: ${SUB_STATE}";

	systemctl status ${SYSTEMD_SERVICE};

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function systemd_start()
{
	if [ ! -e ./.env ];
	then
		echo "ERROR: you must make .env file";
		return 0;
	fi

	export $(cat .env);

	if [ "${SYSTEMD_SERVICE}" == "" ];
	then
		echo "ERROR: you must set SYSTEMD_SERVICE";
		return 1;
	fi

	systemctl restart rsyslog;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[start()]: 2";
		return 1;
	fi

	systemctl daemon-reload &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[start()]: 3";
		return 1;
	fi

	systemctl start "${SYSTEMD_SERVICE}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[start()]: 4";
		return 1;
	fi

	STATE="$(systemctl show ${SYSTEMD_SERVICE} | grep -- 'ActiveState=' | sed -e 's/.*=//g')";
	echo "state: ${STATE}";

	if [ "${STATE}" != "active" ]; # ActiveState=active
	then
		echo "ERROR[start()]: 7";
		return 1;
	fi

	SUB_STATE="$(systemctl show ${SYSTEMD_SERVICE} | grep -- 'SubState=' | sed -e 's/.*=//g')";
	echo "sub_state: ${SUB_STATE}";

	if [ "${SUB_STATE}" != "running" ]; # SubState=running
	then
		echo "ERROR[start()]: 8";
		return 1;
	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function systemd_stop()
{
	if [ ! -e ./.env ];
	then
		echo "ERROR: you must make .env file";
		return 0;
	fi

	export $(cat .env);

	if [ "${SYSTEMD_SERVICE}" == "" ];
	then
		echo "ERROR: you must set SYSTEMD_SERVICE";
		return 1;
	fi

	STATE="$(systemctl show ${SYSTEMD_SERVICE} | grep -- 'ActiveState=' | sed -e 's/.*=//g')";
	if [ "${STATE}" == "inactive" ]; # ActiveState=active
	then
		echo "ERROR[stop()]: 1";
		return 0;
	fi

	systemctl stop "${SYSTEMD_SERVICE}";
	if [ "${?}" != "0" ];
	then
		echo "ERROR[stop()]: 3";
		return 1;
	fi

	if [ -e /var/log/www/${SYSTEMD_SERVICE}.log ];
	then
		UNIXTIME=$(date +'%s');
		mv /var/log/www/${SYSTEMD_SERVICE}.log /var/log/www/${SYSTEMD_SERVICE}.log."${UNIXTIME}" &> /dev/null;
		if [ "${?}" != "0" ];
		then
			echo "ERROR[stop()]: 4";
			return 1;
		fi
	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function systemd_restart()
{
	systemd_stop;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[restart()]: 1";
		return 1;
	fi

	systemd_start;
	if [ "${?}" != "0" ];
	then
		echo "ERROR[restart()]: 2";
		return 1;
	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# show help
function help()
{
	echo "example: ${1} [ gc | log | status | start | stop | restart ]";
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
	local OPERATION="${1}";
	local STATUS;


	if [ "${OPERATION}" == "gc" ]
	then
		systemd_gc;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "log" ]
	then
		systemd_log;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "status" ]
	then
		systemd_status;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "start" ]
	then
		systemd_start;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "stop" ]
	then
		systemd_stop;
		STATUS="${?}";
		return "${STATUS}";
	fi


	if [ "${OPERATION}" == "restart" ]
	then
		systemd_restart;
		STATUS="${?}";
		return "${STATUS}";
	fi


	help "${0}";


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
