#!/bin/sh
# Script para configurar o SSL no cloud Ubuntu Server 20.04 LTS 64 bits
#
# Autor: Leandro Luiz
# email: lls.homeoffice@gmail.com

# Caminho das bibliotecas
PATH=.:$(dirname $0):$PATH
. lib/cloud.lib		|| exit 1

ssl_install()
{

	echo "Installing certbot..."
	apt-get -y install certbot
	
}

ssl_create()
{
	
	ssl_clean

	echo " -- Stop Services -- "
	iptables -F -t nat
	service tomcat stop

	echo " -- Delete Keystore -- "
	rm -fv ${KEYSTORE}

	echo " -- Recreate Keystore -- "
	keytool -genkey -noprompt -alias ${ALIAS} -dname "CN=${DNAME}, OU=${USER}, O=${USER}, L=Uberlandia, S=MG, C=BR" -keystore ${KEYSTORE} -storepass "${PASSWORD}" -KeySize 2048 -keypass "${PASSWORD}" -keyalg RSA

	echo " -- Build CSR -- "
	keytool -certreq -alias ${ALIAS} -file request.csr -keystore ${KEYSTORE} -storepass "${PASSWORD}"

	echo " -- Request Certificate -- "
	certbot certonly --csr ./request.csr --standalone

	echo " -- import Certificate -- "
	keytool -import -trustcacerts -alias ${ALIAS} -file 0001_chain.pem -keystore ${KEYSTORE} -storepass "${PASSWORD}"

	echo " -- Restart services -- "
	service tomcat start
	iptables-restore -n < ${FILE_RULES}

	ssl_clean
	ssl_show
	
}

ssl_clean()
{

	echo " -- Cleaning SSL -- "
	rm -fv request.csr
	rm -fv *.pem
	
}

ssl_show()
{
	
	chown -v tomcat.tomcat ${KEYSTORE}
	
	echo "Showing private key..."
	keytool -list -v -keystore ${KEYSTORE} -storepass ${PASSWORD} | less
	
}

case "$1" in
	install)
		ssl_install
		;;
	create)
		ssl_create
		;;
	show)
		ssl_show
		;;
	*)
		echo "Use: $0 {install|create|show}"
		exit 1
		;;
esac
