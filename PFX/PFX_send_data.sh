#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_send_data.sh 24/12/2014
# MPE
#
#########################################################################

PATH_LOG="/var/log/pfx"
PATH_PFX="/usr/local/pfx"



#Initialisation des Libs Variable PFX
load_libraries()
{
	source /etc/pfx/Var.sh
	source $PATH_PFX/lib/lib
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


#Initialisation des variables Poller
init_variable()
{
debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

ERREUR=0
POLLER_NAME=""
POLLER_NAME=$($PCAT $CONFNAGIOS | $PGREP POLLERNAME | $PCUT -d "=" -f2)
HOST_CENTRAL=""
HOST_CENTRAL=$($PCAT $CONFNAGIOS | $PGREP CENTRALIP | $PCUT -d "=" -f2)
debug "POLLER_NAME= $POLLER_NAME, HOST_CENTRAL= $HOST_CENTRAL"
if [ "$POLLER_NAME" = "" ] || [ "$HOST_CENTRAL" = "" ]; then
        echo "Erreur de configuration du poller, merci de mettre a jour le fichier Poller-Conf"
		ERREUR=1
        exit 1
fi
}

## obtention numero du depot
recup_num_depot()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	PATH_DEPOS=""
	PATH_DEPOS=$($PGREP -nr $POLLER_NAME correspondance | head -n 1 | cut -d":" -f1)

	if [ -z "$PATH_DEPOS" ]; then		
		echo "Le poller $POLLER_NAME n existe pas dans le referenciel..."
		PATH_DEPOS="0"
		ERREUR="1"
		exit 1
	fi
	
}



#Supression Archive de + de 30 j
remove_old_arch()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	echo "Suppression des archives anterieur a 30 jours"
	#Numero du mois dernier
	DATEM2=$(date --date='-1 month' +%m)

	rm -f  $PATH_VAR/archives/$NAGLOG-$DATEM2-$DATEJ-$DATEY-00.log
	rm -f  $PATH_VAR/archives/$NAGPERF-$DATEM2-$DATEJ-$DATEY-00

}

#Creation Nagios PerfTrace
arch_perftrace()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	$PATH_BIN/nagiostats -c $PATH_CONF/nagios.cfg > $PATH_VAR/nagiosPerfTrace.$PATH_DEPOS
}

#Preparation du fichier de log et Archivage (Archive de 30 Jours)
prepa_log()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
		
	if [ -f $NAGIOSLOG ];then
		mv $NAGIOSLOG $PATH_VAR/$NAGLOG.$PATH_DEPOS.$INDEX_SESSION
		$PCAT $PATH_VAR/$NAGLOG.$PATH_DEPOS.$INDEX_SESSION >> $NAGARCH
	else
		debug "Pas de fichier $NAGIOSLOG a traiter"
	fi
}

#Preparation du fichier de perf et Archivage (Archive de 30 Jours)
prepa_perf()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
		
	if [ -f $PERFDATA ];then
		mv $PERFDATA $PATH_VAR/$NAGPERF.$PATH_DEPOS.$INDEX_SESSION
		$PCAT $PATH_VAR/$NAGPERF.$PATH_DEPOS.$INDEX_SESSION >> $NAGARCH
	else
		debug "Pas de fichier $PERFDATA a traiter"
	fi
}

#Envoi des fichiers logs Nagios
envoi_log()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	for FILEA in $(ls $NAGLOG.$PATH_DEPOS*)
	do
		echo "Envoi du fichier $FILEA"
		envoi_ftp $LOGDEPOT $FILEA
		rm $FILEA
	done
}

#Envoi des fichiers Perfdata
envoi_perf()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	for FILEB in $(ls $NAGPERF.$PATH_DEPOS*)
	do
		echo "Envoi du fichier $FILEB"
		envoi_ftp $LOGDEPOT $FILEB
		rm $FILEB
	done
}

###################################################

#            Programme         

###################################################

load_libraries

# Si argument "debug" alors debug_on
[ "$1" == "debug" ] && debug_on || debug() { echo -n ""; }

init_variable
date
ping_poller_maitre

cd $PATH_NAGIOS
cd $PATH_PFX
recup_num_depot

cd $PATH_NAGIOS
remove_old_arch
arch_perftrace
prepa_log
prepa_perf
cd $PATH_VAR
#Envoi des fichiers
envoi_log
envoi_perf

exit 0