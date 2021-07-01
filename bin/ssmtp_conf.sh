#!/bin/sh
# Script para configurar o Ssmtp no cloud Ubuntu Server 20.04 LTS 64 bits
#
# With the following Google settings:
# IMAP enabled
# Allow less secure apps is ON
# Turn on 2-Step Verification
# Set an app-password for ssmtp and save it 
#
# Autor: Leandro Luiz
# email: lls.homeoffice@gmail.com

ssmtp_install()
{
	
	echo "Installing ssmtp..."
	apt-get -y install ssmtp sharutils zip unzip mc
	
}

ssmtp_config()
{
	
	ARQ_CONFIG="/etc/ssmtp/revaliases"
	
	echo "root:${EMAIL}:smtp.gmail.com:587" 			> ${ARQ_CONFIG}
	
	echo "Changing permissions for revaliases..."
	ssmtp_change
	
	ARQ_CONFIG="/etc/ssmtp/ssmtp.conf"
	
	echo "root=${EMAIL}"		  						> ${ARQ_CONFIG}
	echo "hostname=${HOSTNAME}"							>> ${ARQ_CONFIG}
	#echo "#rewriteDomain="								>> ${ARQ_CONFIG}
	echo "AuthUser=${EMAIL}"							>> ${ARQ_CONFIG}
	echo "AuthPass=${PASSWORD}"							>> ${ARQ_CONFIG}
	echo "FromLineOverride=YES"							>> ${ARQ_CONFIG}
	echo "Mailhub=smtp.gmail.com:587"					>> ${ARQ_CONFIG}
	#echo "#UseTLS=YES"									>> ${ARQ_CONFIG}
	echo "UseSTARTTLS=YES"								>> ${ARQ_CONFIG}
	echo "AuthMethod=LOGIN"								>> ${ARQ_CONFIG}
	
	echo "Changing permissions for ssmtp conf..."
	ssmtp_change
	
}

ssmtp_change()
{
	
	chown -v root.mail ${ARQ_CONFIG}
	
	chmod -v 640 ${ARQ_CONFIG}
	
	cat ${ARQ_CONFIG}
	
}

if [ "$EUID" -ne 0 ]; then
	echo "Rodar script como root"
	exit 1
  
fi

HOSTNAME=`hostname`
EMAIL=`git config user.email`

if [ -z "${EMAIL}" ]; then
		
	echo "Not found a email!"
	echo "Use: git_conf.sh email {EMAIL}"
	exit 1
	
fi

USER=${EMAIL%@*}

PASSWORD=`git config user.ssmtp`

if [ -z "${PASSWORD}" ]; then
		
	echo "Use: git_conf.sh ssmtp {SSMTP_APP_PASSWORD}"
	exit 1
	
fi

case "$1" in
	install)
		ssmtp_install
		;;
	config)
		
		if [ -z "${USER}" -o -z "${EMAIL}" -o -z "${PASSWORD}" ]; then
		
			echo "Usuário, Email ou Senha não informado!"
			echo "Use: git_conf.sh {name|email|password} [NAME|EMAIL|PASSWORD]"
			exit 1
		
		fi
		
		ssmtp_config
		;;
	all)
		ssmtp_install
		ssmtp_config
		;;
	*)
		echo "Use: $0 {all|install|config}"
		exit 1
		;;
esac
