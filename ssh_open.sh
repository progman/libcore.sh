#!/bin/bash
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# 0.0.2
# Alexey Potehin <gnuplanet@gmail.com>, http://www.gnuplanet.ru/doc/cv
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

	if [ "${SSH_PASSWORD}" == "" ];
	then
		echo "FATAL: var \"SSH_PASSWORD\" is not set";
		return 1;
	fi

	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
# general function
function main()
{
# check depends tools
	check_prog "echo sshpass";
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
	fi


	var_check;
	if [ "${?}" != "0" ];
	then
		return 1;
	fi


#in OPENVPN_CONFIG you must change 'auth-user-pass' to 'auth-user-pass /root/.hostname_vpn.auth'
#cat /root/.hostname_vpn.auth
#login
#password


# you can use ssh via openvpn
	if [ "${OPENVPN_CONFIG}" != "" ];
	then
# start openvpn if it is not started
		if [ "$(ps -fe | grep openvpn | grep -v grep | wc -l | { read a b; echo ${a}; })" == "0" ];
		then
# check current tun count
			TUN_COUNT_OLD="$(ip -br link | awk '{ print $1 }' | grep tun | wc -l | { read a b; echo ${a}; })";

# start openvpn
			openvpn "${OPENVPN_CONFIG}" &> /dev/null < /dev/null &

# wait to change tun count
			while true;
			do
				TUN_COUNT_NEW="$(ip -br link | awk '{ print $1 }' | grep tun | wc -l | { read a b; echo ${a}; })";
				if [ "${TUN_COUNT_OLD}" != "${TUN_COUNT_NEW}" ];
				then
					break;
				fi
				sleep 0.1;
			done;
		fi
	fi


#cat .ssh_hostname
#export SSH_HOST='host';
#export SSH_PORT='port';
#export SSH_LOGIN='login';
#export SSH_PASSWORD='password';
#export OPENVPN_CONFIG='PATH_TO_OPENVPN_CONFIG'; # you can skip it


# connect via ssh
	export SSHPASS="${SSH_PASSWORD}";
	sshpass -e ssh -o port="${SSH_PORT}" "${SSH_LOGIN}@${SSH_HOST}";
	if [ ${?} != "0" ];
	then
		echo "maybe it is first enter, try use: ssh -o port=${SSH_PORT} ${SSH_LOGIN}@${SSH_HOST}";
		return 1;
	fi


	return 0;
}
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
main "${@}";

exit "${?}";
#-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------#
