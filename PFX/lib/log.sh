#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
###################################################
# log.sh                                          #
# Auteur :   Matthieu PERRIN (OBS)                #
# Fonction : Rotation des fichiers de logs        #
###################################################


PATH_LOG="/var/log/pfx"

# ----------------------------------------------------------------------------- #
# Rotation SI fichier de log superieur a 1Mo
log_rotation()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	fichier_log=$1
        if [ -f $fichier_log ]; then
                TAILLE_LOG=$(stat -c %s $fichier_log)
                if [ ${TAILLE_LOG} -ge 1000000 ]; then
            echo "Taille du fichier : ${TAILLE_LOG} octets"
            echo "Rotation ..."
            mv -f $fichier_log.1 $fichier_log.2
            mv -f $fichier_log $fichier_log.1
                fi
        fi
}

# ----------------------------------------------------------------------------- #
# Rotation des fichiers de logs
rotation_log_dir()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	cd $PATH_LOG

	for FILEB in $(ls *.log)
	do
		log_rotation $FILEB
	done

}

# ----------------------------------------------------------------------------- #
check_log_directory()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"

	PATH_LOG="/usr/local/nagios/PFX/log"

	# compte le volume totale des fichiers de logs
	oct=10000000
	#oct=$(find $PATH_LOG -name '*.log' -exec ls -l {} \; | awk '{ Total += $5} END { print Total }')

	# Si totale > 1000000 
	if [ $oct -gt 1000000 ]
	then
		rotation_log_dir
	fi

}

# ----------------------------------------------------------------------------- #
# Rotation des logs tout les 30 min
hour_log_rotate()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	min=$(date +%M)
	if [ $min -eq 30 ]
	then
		check_log_directory
	fi
}