#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.6
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
# check var list
function var_check()
{
	if [ "${SSH_HOST}" == "" ];
	then
		echo "FATAL: var \"SSH_HOST\" is not set";
		return 1;
	fi

	if [ "${SSH_PORT}" == "" ];
	then
		echo "FATAL: var \"SSH_PORT\" is not set";
		return 1;
	fi

	if [ "${SSH_LOGIN}" == "" ];
	then
		echo "FATAL: var \"SSH_LOGIN\" is not set";
		return 1;
	fi

#	if [ "${SSH_PASSWORD}" == "" ];
#	then
#		echo "FATAL: var \"SSH_PASSWORD\" is not set";
#		return 1;
#	fi

	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
function check_connect()
{
# check depends tools
	check_prog "nc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	nc -w 1 -z "${SSH_HOST}" "${SSH_PORT}" &> /dev/null < /dev/null;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# use openvpn
function use_openvpn()
{
#in OPENVPN_CONFIG you must change 'auth-user-pass' to 'auth-user-pass /root/.hostname_vpn.auth'
#cat /root/.hostname_vpn.auth
#login
#password


# you can use ssh via openvpn
	if [ "${FLAG_OPENVNC}" != "true" ];
	then
		return 0;
	fi


# check depends tools
	check_prog "openvpn";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# chech config file
	if [ ! -e "${OPENVPN_CONFIG}" ];
	then
		echo "FATAL: OPENVPN_CONFIG is not found";
		return 1;
	fi


# start openvpn if it is not started
	if [ "$(ps -fe | grep openvpn | grep -v grep | wc -l | { read a b; echo ${a}; })" == "0" ];
	then

# start openvpn
		openvpn "${OPENVPN_CONFIG}" &> /dev/null < /dev/null &
		if [ "${?}" != "0" ];
		then
			echo "FATAL: openvpn did not start";
			return 1;
		fi


# wait to change tun count
		while true;
		do
			check_connect;
			if [ "${?}" == "0" ];
			then
				break;
			fi
			sleep 0.1;
		done;

	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# use vpnc
function use_vpnc()
{
# you can use ssh via vpnc
	if [ "${FLAG_VPNC}" != "true" ];
	then
		return 0;
	fi


# check depends tools
	check_prog "vpnc";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# start vpnc if it is not started
	if [ "$(ps -fe | grep vpnc | grep -v grep | wc -l | { read a b; echo ${a}; })" == "0" ];
	then

# start vpnc
		vpnc &> /dev/null < /dev/null &
		if [ "${?}" != "0" ];
		then
			echo "FATAL: vpnc did not start";
			return 1;
		fi


# wait to change tun count
		while true;
		do
			check_connect;
			if [ "${?}" == "0" ];
			then
				break;
			fi
			sleep 0.1;
		done;

	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo";
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check --help option
	if  [ "${1}" == "-h" ] || [ "${1}" == "-help" ] || [ "${1}" == "--help" ];
	then
		echo "example: ${0} ENV_FILE";
		echo;
		echo "\$ cat ENV_FILE";
		echo "export SSH_HOST='host';";
		echo "export SSH_PORT='port';";
		echo "export SSH_LOGIN='login';";
		echo "export SSH_PASSWORD='password'; # you can skip it";
		echo;
		echo "export FLAG_OPENVNC='true';";
		echo "export OPENVPN_CONFIG='PATH_TO_OPENVPN_CONFIG'; # you can skip it";
		echo "export FLAG_VPNC='false';";
		echo;
		echo "#export VPN_HOST='vpn_host';";
		echo "#export VPN_GROUP_NAME='vpn_group_name';";
		echo "#export VPN_GROUP_PASSWORD='vpn_group_password';";
		echo "#export VPN_USER_NAME='vpn_user_name';";
		echo "#export VPN_USER_PASSWORD='vpn_user_password';";

		return 0;
	fi


# check env file
	if [ "${1}" != "" ] && [ -e "${1}" ];
	then
		source "${1}";
	fi


# check vars
	var_check;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check openvpn
	use_openvpn;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# check vpnc
	use_vpnc;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


# connect via ssh
	if [ "${SSH_PASSWORD}" != "" ];
	then

# check depends tools
		check_prog "sshpass";
		if [ "${?}" != "0" ];
		then
			return 1;
		fi


		export SSHPASS="${SSH_PASSWORD}";
		sshpass -e ssh -o port="${SSH_PORT}" "${SSH_LOGIN}@${SSH_HOST}";
		if [ ${?} != "0" ];
		then
			echo "maybe it is first enter, try use: ssh -o port=${SSH_PORT} ${SSH_LOGIN}@${SSH_HOST}";
			return 1;
		fi

	else

		ssh -o port="${SSH_PORT}" "${SSH_LOGIN}@${SSH_HOST}";
		if [ ${?} != "0" ];
		then
			echo "maybe it is first enter, try use: ssh -o port=${SSH_PORT} ${SSH_LOGIN}@${SSH_HOST}";
			return 1;
		fi

	fi


	return 0;
}
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
