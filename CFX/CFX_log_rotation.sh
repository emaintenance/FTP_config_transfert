#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#########################################################################


PATH_LOG="/var/log/cfx"


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


rotation_log_dir