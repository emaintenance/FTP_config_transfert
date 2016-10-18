#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_get_command.sh 21/05/2014
# MPE
#
#########################################################################
# script _reception_cmd
# auteur : Florent Aubert
# version 0.0 du 29/01/10
#
# V1.0 12/04/2010 JM Test présence du central avant toute operation
# V1.1 18/07/2012 CTR Ajout de la conf generique
# description :
# - recupere sur le serveur FTP du central les fichiers centcore.X
# - copie ces fichiers dans poller.cmd
# - supprime les fichiers du serveurs FTP
# - envoi les commandes dans nagios.cmd
# CTR - 07/02/2013 Optimisation du code et generisation des commandes
# CTR - 05/03/2013 Mise en place des Libs V1.0
# CTR - 05/08/2013  Mise en place de la nouvelle synchro V2.0
#########################################################################

PATH_LOG="/var/log/pfx"
PATH_PFX="/usr/local/pfx"


#Initialisation des Libs Variable PFX
load_libraries()
{
	source /etc/pfx/Var.sh
	source $PATH_PFX/lib/lib
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


get_cmd_file()
{
debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
cd $PATH_NAGIOS
recup_ftp transfert $POLLER
if [ -f $PATH_NAGIOS/$POLLER ]; then
	suppr_ftp transfert $POLLER
fi
}

redemarre_nagios()
{
debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
		/etc/init.d/nagios stop
        sleep 2
		/usr/bin/killall -9 nagios
		sleep 1
        /etc/init.d/nagios start
}

cmd2nagios()
{
if [ -f $PATH_NAGIOS/$POLLER ]; then
	date
	echo "Nouvelle commande disponible => envoi des nouvelles commande a nagios"
	echo "Envoi des commandes suivante au Poller
	"
	$PCAT $PATH_NAGIOS/$POLLER

	#Envoi des commandes a Nagios
	$PCAT $PATH_NAGIOS/$POLLER >> $PATH_CMD
	
	#Traitement des commandes
	debug "Test du rechargement Nagios"
	if [ $($PCAT $PATH_NAGIOS/$POLLER | $PGREP "NEWCONF" | $PWC -l) -ge "1" ]; then
		echo "NEWCONF : Recupere la configuration nagios"
		# Recupere la configuration nagios
		$PATH_PFX/PFX_get_config.sh >> $PATH_LOG/PFX_get_config.log
		sleep 1
		/etc/init.d/nagios reload
	elif [ $($PCAT $PATH_NAGIOS/$POLLER | $PGREP "RELOAD" | $PWC -l) -ge "1" ]; then
		echo "RELOAD : recharge_nagios"
		#recharge_nagios
		/etc/init.d/nagios reload
	elif [ $($PCAT $PATH_NAGIOS/$POLLER | $PGREP "RESTART" | $PWC -l) -ge "1" ]; then
		echo "RESTART : redemarre_nagios"
		redemarre_nagios
	fi
	
	if [ $($PCAT $PATH_NAGIOS/$POLLER | $PGREP "UPDATE" | $PWC -l) -ge "1" ]; then
		echo "Mise a jour de PFX"
		# Mise a jour de PFX
		cd $PATH_NAGIOS
		
		echo "UPDATE" > /tmp/update_pfx
		
		cd $PATH_PFX
	fi
	echo "Suppression du fichier $POLLER"
	rm -f $PATH_NAGIOS/$POLLER
	
	# test pour acceler remonter info
	pgrep send_data > /dev/null || $PATH_PFX/PFX_send_data.sh $1 >> $PATH_LOG/PFX_send_data.log &
else
	debug "Pas de nouvelle commande a traiter => Sortie du programme"
fi
}

###################################################

#            Programme         

###################################################

load_libraries

# Si argument "debug" alors debug_on
[ "$1" == "debug" ] && debug_on || debug() { echo -n ""; }


init_variable
ping_poller_maitre

POLLER=$POLLER_NAME.cmd
cd $PATH_NAGIOS


debug "Lancement de la reception des commandes externes"
get_cmd_file #recup_fich_cmd
cmd2nagios #envoi_cmd_nagios
	