#!/bin/sh
# Script para configurar o Ssmtp no cloud Ubuntu Server 20.04 LTS 64 bits
#
# Link to enable this app to send email on Google
# https://accounts.google.com/DisplayUnlockCaptcha
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
	
	echo "root:${USER}@gmail.com:smtp.gmail.com:587" >> ${ARQ_CONFIG}
	
	echo "Changing permissions for revaliases..."
	chown -v root.mail ${ARQ_CONFIG}
	chmod -v 640 ${ARQ_CONFIG}
	cat ${ARQ_CONFIG}
	
	ARQ_CONFIG="/etc/ssmtp/ssmtp.conf"
	
	echo "root=${USER}@gmail.com"  						> ${ARQ_CONFIG}
	echo "hostname=localhost"							>> ${ARQ_CONFIG}
	echo "rewriteDomain="								>> ${ARQ_CONFIG}
	echo "AuthUser=${USER}"								>> ${ARQ_CONFIG}
	echo "AuthPass=${PASSWORD}"							>> ${ARQ_CONFIG}
	echo "FromLineOverride=YES"							>> ${ARQ_CONFIG}
	echo "Mailhub=smtp.gmail.com:587"					>> ${ARQ_CONFIG}
	echo "UseTLS=YES"									>> ${ARQ_CONFIG}
	echo "UseSTARTTLS=YES"								>> ${ARQ_CONFIG}
	echo "AuthMethod=LOGIN"								>> ${ARQ_CONFIG}
	
	echo "Changing permissions for ssmtp conf..."
	chown -v root.mail ${ARQ_CONFIG}
	chmod -v 640 ${ARQ_CONFIG}
	cat ${ARQ_CONFIG}
	
}

if [ "$EUID" -ne 0 ]; then
	echo "Rodar script como root"
	exit 1
  
fi

USER="$2"
PASSWORD="$3"

case "$1" in
	install)
		ssmtp_install
		;;
	config)
		
		if [ -z "${USER}" -o -z "${PASSWORD}" ]; then
		
			echo "Usuário ou Senha não informado!"
			echo "Use: $0 {config} {user} {password}"
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
