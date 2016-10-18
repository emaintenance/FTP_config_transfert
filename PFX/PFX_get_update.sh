#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_get_update.sh 24/12/2014
# MPE
#
#########################################################################

#exit 1

#Initialisation des Libs Variable PFX
load_libraries()
{
	# SCRIPT AUTONOME : AUCUNE DEPENDANCE
		
	
	PATH_PFX="/usr/local/pfx"
	PATH_NAGIOS="/usr/local/nagios"
	CONFNAGIOS="/etc/pfx/Poller-Conf"
	PATH_CONF="$PATH_NAGIOS/etc"
	FTP_LOCAL_AUTOCFG="/home/pfx/transfert/AutoConf-Poller"
	HOST_CENTRAL=$(cat $PATH_NAGIOS/etc/Poller-Conf | grep CENTRALIP | cut -d'=' -f2)
	
}

# test presence du central
ping_poller_maitre()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	
	/bin/ping -q -c 1 $HOST_CENTRAL > /dev/null
	case $? in
		0)
			debug "Serveur central $HOST_CENTRAL joignable"
			;;
		*)
			echo "Serveur central $HOST_CENTRAL injoignable"
			exit 1
			;;
	esac
}

# Pour compatibilite
start_autoconf()
{
	[ -f $PATH_CONF/AutoConf.sh ] && $PATH_CONF/AutoConf.sh &
}

# ----------------------------------------------------------------------------- #
# Effectue le transfert
ftp_query()
{
debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
ftp_server=$HOST_CENTRAL

		ftp_user="ftp"
		ftp_pass="ftp"
debug "dossier= $1 , fichier = $2 , server= $ftp_server, u= $ftp_user , p= $ftp_pass"

DOSSIER=$1

FILE=$2
ftp -i -n 1>/tmp/ftp.tmp 2>&1 << EOF
open $ftp_server
user $ftp_user $ftp_pass
bin
cd $DOSSIER
$commande $FILE
close
bye
EOF


controle_transmission
}

# ----------------------------------------------------------------------------- #
# Verifie la reussite du transfert
controle_transmission()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

		RESULT=""
	if [ -f ftp.tmp ]; then
		RESULT=$(/bin/cat ftp.tmp | grep -v "Please login" | grep -v "KERBEROS")
		debug "RESULT=$RESULT"
	fi
	if [ "$RESULT" = "" ]; then
		echo "Transfert de $DOSSIER $FILE OK"
		RESULT="OK"
		rm -f ftp.tmp
	else
		echo "Probleme de transmission FTP : $RESULT"
		rm -f ftp.tmp
	fi
	debug "Fin du Module recup_ftp
	"
}

# ----------------------------------------------------------------------------- #
# recupere un fichier
recup_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="get"
	ftp_query $1 $2
}

# Telecharge le dossier PFX
dl_pfx()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	## connexion au serveur ftp et recuperation des fichiers
	debug "Telechargement des fichiers de conf ..." 
	mkdir -p $PATH_PFX/{lib,log}
	cd $PATH_PFX/..
	
	cd /tmp
	
	# Telecharge le dossier PFX
	tentative=0
	FICHOK=0
	while [ $FICHOK = 0 ]; do
		echo "Tentative de recuperation des fichiers de conf"
		recup_ftp transfert/AutoConf-Poller/ pfx.tar.gz
		if [ -f pfx.tar.gz ]; then
			FICHOK=1
		else
			echo "Probleme de recuperation des fichiers PFX, relance dans 5 secondes"
			sleep 5
			tentative=$((tentative+1))
			[ "$tentative" -gt 3 ] && FICHOK=2
		fi
	done
	
	if [ $FICHOK = 1 ]; then
	
	
		tar -C /tmp/ -zxf pfx.tar.gz
		/bin/cp -Rf /tmp/pfx/* /usr/local/pfx/
		
		# Met a jour le package du repertoire FTP pour poller fils
		cp -f pfx.tar.gz $FTP_LOCAL_AUTOCFG/pfx.tar.gz
		rm -f pfx.tar.gz
		date > $PATH_PFX/update
		mkdir -p $PATH_PFX/{lib,log}
		
	fi
	
	cd $PATH_PFX
	## changemnet des modes et users
	chmod -Rf 777 *
	chown -Rf nagios.nagios *
	
	chmod -Rf 777 /usr/local/pfx
	chown -Rf nagios.nagios /usr/local/pfx
	chown -Rf nagios.nagios /var/log/pfx
}

###################################################

#            Programme         

###################################################

echo -e "\n######  ${BASH_SOURCE[0]}  ######\n"

# Efface le fichier indiquant une nouvelle version logiciel pour le cron et passage en root
rm -f /tmp/update_pfx

load_libraries

# Si argument "debug" alors debug_on
[ "$1" == "debug" ] && debug() { echo $1; } || debug() { echo -n ""; }

# Stop PFX
/etc/init.d/pfx stop &

#start_autoconf
ping_poller_maitre
dl_pfx

cd ; cd -
# Instalation de PFX
$PATH_PFX/PFX_install.sh
mkdir -p /var/log/pfx
chmod 750 /var/log/pfx -R
chown -R nagios.nagios /var/log/pfx
/etc/init.d/pfx start
