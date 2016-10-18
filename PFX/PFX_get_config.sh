#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_get_config.sh 23/12/2014
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


redemarre_nagios()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	/etc/init.d/nagios stop &
	sleep 2
	/usr/bin/killall -9 nagios
	sleep 1
	/etc/init.d/nagios start &
}


#Test du fonctionnement de Ndomod.o
test_ndomod()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

	case $($PNETSTAT -nap | $PGREP $HOST_CENTRAL:5668 | $PWC -l) in
		1)
			debug "Ndo fonctionne correctement"
			;;
		*)
			echo "NDO ne fonctionne plus sur ce poller, redemarrage de nagios"
			redemarre_nagios
			;;
	esac
}

#Controle de la presence de Nagios en Process
test_nagios()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

	case $($PPS aux | $PGREP nagios.cfg | $PGREP -v grep | $PGREP Ssl | $PWC -l) in
		0)
			echo "Nagios ne semble pas fonctionnel => Redemarrage des services eMaintenance"
			redemarre_nagios
			;;
		*)	
			debug "Nagios fonctionne correctement"
			;;
	esac
}


#Recuperation et traitement du fichier correspondance
telecharge_correspondance()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

	recup_ftp / correspondance

	#Controle de l'etat de la transmission
	case $RESULT in
		OK)
			debug "Recuperation des informations presente dans Correspondance"
			;;
		*)	
			echo 'Fichier correspondance introuvable. Arret force'
			exit 1
			;;
	esac
}

## obtention date de mise a jour eMaintenance
recup_date_maj()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	cd $PATH_PFX
	DATE_MAJ=0
	DATE_MAJ=$(/usr/bin/tail -n 1 correspondance)
	debug "Date de la mise a jour actuelle : $($PDATE -d @$DATE_MAJ)"

}


## obtention numero du depot
recup_num_depot()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	PATH_DEPOS=""
	PATH_DEPOS=$($PGREP -nr $POLLER_NAME correspondance | cut -d":" -f1)

	if [ -z "$PATH_DEPOS" ]; then		
		echo "Le poller $POLLER_NAME n existe pas dans le referenciel..."
		PATH_DEPOS="0"
		ERREUR="1"
		exit 1
	fi
	
}


## suppression de la conf actuelle
purge_conf()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
		
	## suppression des anciens fichiers de conf
	debug "Suppression des anciens fichiers de configuration  ..."
	mkdir -p $PATH_CONF
	rm -Rf $PATH_CONF/*

	debug "Ajout des fichiers initiaux  ..."
	cp -Rf $PATH_UTILS/* $PATH_CONF
}

update_sys()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	if [ -f $PATH_CONF/update.sh ]; then
		chmod +x $PATH_CONF/update.sh
		$PATH_CONF/update.sh &
	fi
}

# Recuperation des confs nagios
recup_conf()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	
	## connexion au serveur ftp et recuperation des fichiers
	debug "Telechargement des fichiers de conf ..." 
	cd $PATH_CONF
	tentative=0
	FICHOK=0
	while [ $FICHOK = 0 ]; do
		echo "Tentative de recuperation des fichiers de conf"
		recup_doss_ftp $PATH_DEPOS
		if [ -f timeperiods.cfg ]; then
			FICHOK=1
		else
			echo "Probleme de recuperation des fichiers de conf, relance dans 5 secondes"
			sleep 5
			tentative=$((tentative+1))
			[ "$tentative" -gt 3 ] && FICHOK=2
		fi
		
		if [ $FICHOK = 1 ]; then	
			echo "Recuperation des fichiers de conf OK
			"
		else
			echo "ERREUR lors de la recuperation des fichiers de conf. Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]} "
		fi
	done

	## changemnet des modes et users
	chmod -Rf 777 *
	chown -Rf nagios.nagios *
	
	/bin/cp -rf /usr/local/nagios/etc/Poller-Conf /usr/local/nagios/Poller-Conf

	update_sys
}


verif_update()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

	[ "$1" == "force" ] && echo 0 > $PATH_NAGIOS/DATE_CONF

	DATE_CONF="0"
	DATE_CONF=$($PCAT $PATH_NAGIOS/DATE_CONF)
	
	if [ "$DATE_CONF" = "" ]; then
		DATE_CONF="0"
	fi
	
	if [ "$DATE_MAJ" -le "$DATE_CONF" ]; then
		echo ""
		echo " ###########################################################################"
		echo "  Pas de mise a jour : la configuration actuelle est la plus recente ...    "
		echo "  Pour forcer une mise a jour du depot, ajouter le parametre force          "
		echo "       ex:  $0 force                                                        "
		echo " ###########################################################################"
		echo ""
	else
		date 
		echo "Une mise a jour est disponible"
		
		
		echo -n "$DATE_MAJ" > $PATH_NAGIOS/DATE_CONF
		
		echo "UPDATE" > /tmp/update_pfx
		
	fi
	
	echo -n "$DATE_MAJ" > $PATH_NAGIOS/DATE_CONF
}

###################################################

#            Programme         

###################################################

echo -e "\n######  ${BASH_SOURCE[0]}  ######\n"


load_libraries

# Si argument "debug" alors debug_on
[ "$1" == "debug" ] && debug_on || debug() { echo -n ""; }

init_variable
ping_poller_maitre

cd $PATH_PFX
telecharge_correspondance
recup_num_depot
cd $PATH_NAGIOS
purge_conf
recup_conf
redemarre_nagios # doublon ?
test_nagios

# mise a jour du systeme
recup_date_maj
#verif_update $1

# Command post config
[ -f ${PATH_CONF}/AutoConfPFX.sh ] && bash ${PATH_CONF}/AutoConfPFX.sh &

echo "########################################################"
echo "#Recuperation de la configuration eMaintenance OK   !!!#"
echo "########################################################"	
exit 0