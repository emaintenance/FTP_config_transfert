#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
###################################################
# PFX_cmd_FTP.sh                                  #
# Auteur :   Matthieu PERRIN (OBS)                #
# Fonction : Transfert en FTP                     #
###################################################

commande=""
ftp_server=""
ftp_user="ftp"
ftp_pass="ftp"


# ----------------------------------------------------------------------------- #
# Effectue le transfert
ftp_query()
{
debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
ftp_server=$HOST_CENTRAL
debug "dossier= $1 , fichier = $2 , server= $ftp_server, u= $ftp_user , p= $ftp_pass"


DOSSIER=$1


FILE=$2
#$PFTP -i -n 1>ftp.tmp 2>&1 << EOF
ftp -i -n 1>ftp.tmp 2>&1 << EOF
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
		#return 0
	else
		debug "Probleme de transmission FTP : $RESULT" 
		rm -f ftp.tmp
		#return 1
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

# ----------------------------------------------------------------------------- #
# recupere plusierus fichiers
recup_multi_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="mget"
	ftp_query $1 $2
}

# ----------------------------------------------------------------------------- #
# recupere un dossier
recup_doss_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="mget"
	file="*"
	
	ftp_query $1 "*"
}

# ----------------------------------------------------------------------------- #
# envoi un fichier
envoi_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="put"
	ftp_query $1 $2
	debug "DossierFTP=$1 fichier=$2"
}

# ----------------------------------------------------------------------------- #
# supprime un fichier distant
suppr_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="delete"
	ftp_query $1 $2
}

# ----------------------------------------------------------------------------- #
# supprime plusieurs fichiers distant
suppr_multi_ftp()
{
	debug "Fonction ${FUNCNAME[0]} de ${BASH_SOURCE[0]}"
	commande="mdel"
	ftp_query $1 $2
}
