#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# script EDF_envoi_cmd.sh
# auteur : C.Triomphe
# version 1.0 du 07/08/2013
#
# description :
# - créer un named pipe pour /var/lib/centreon/centcore.cmd
# - Ecoute les commandes de Centreon et les dispatch dans les depots correspondant
# - Gere les Timestamps des configurations des pollers satellites 
# - Gere le mode de redemarrage des pollers sattellites
#########################################################################
# CFX_envoi_cmd.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm

centcore=$(cat ${centreon_config} | grep cmdFile | cut -d'=' -f 2 |  cut -d '"' -f 2)
CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG

#Variable de programme
PGREP="/bin/grep"
PCAT="/bin/cat"
PCUT="/bin/cut"
 
#Creation du fichier de reception des commandes centreon
creation_pipe()
{
pipe=/var/lib/centreon/centcore.cmd
pipe=${centcore}
rm -f $pipe
trap "rm -f $pipe" EXIT

if [[ ! -p $pipe ]]; then
    mkfifo $pipe
    chmod 666 $pipe
    chown centreon.centreon $pipe
fi
}

#Boucle permettant la lecture du fichier de commande de centreon
lance_boucle()
{
while true
do
	line=$($PCAT < $pipe )
	case ${line[0]} in
         QUITCMD)
		echo "Demande de sortie du programme recu (QUITCMD)"
		break
		;;
         VALIDCMD)
		echo "Demande de validation de fonctionnement recu"
		echo "VALIDCMDOK" > /tmp/validcmd
		;;
	  *)
		if [ "${#line[*]}" -ne "0" ]; then
			echo "$line" | (while read ligne
			do
				prepareligne
			done)
		
		fi
		;;
	esac

done
}

#Analyse et decoupage des lignes recu de centreon
prepareligne()
{
TYPECMD=$(echo $ligne | $PCUT -d ":" -f1)
POLLER=$(echo $ligne | $PCUT -d ":" -f2)
if [ "$POLLER" = "" ]; then
	echo -e "Une erreur de traitement a eu lieu!!!\nla commande suivante n a pas pu etre traitee car l ID du poller est absente\n\n-------------- $ligne --------------\n\n"	
else
	POLLERNAME=$($PCAT ${nagiosCFG}/$POLLER/ndomod.cfg | $PGREP "instance_name" | $PCUT -d "=" -f2)
	if [ $TYPECMD ==  "EXTERNALCMD" ]; then
		CMD=$(echo $ligne | $PCUT -d ":" -f3)	
	fi
	
        # Ajout MPE dec 2015
        [ -f /usr/local/scripts/ajout_lien_heat.sh ] && CMD=$(/usr/local/scripts/ajout_lien_heat.sh "$CMD")
	traiteligne
fi
}

#Traitement de la ligne avec ventilation par poller pour les commandes externe
traiteligne()
{

touch ${nagiosCFG}/transfert/$POLLERNAME.cmd
chown nagios.nagios ${nagiosCFG}/transfert/$POLLERNAME.cmd

	case $TYPECMD in
		EXTERNALCMD)
			echo "$CMD" >> ${nagiosCFG}/transfert/$POLLERNAME.cmd
			;;
		RESTART)
			echo "RESTART" >> ${nagiosCFG}/transfert/$POLLERNAME.cmd
			;;
		RELOAD)
			echo "RELOAD" >> ${nagiosCFG}/transfert/$POLLERNAME.cmd
			;;
		SENDCFGFILE)
			echo "$(date)" > ${nagiosCFG}/$POLLER/lastupdate
			echo "NEWCONF" >> ${nagiosCFG}/transfert/$POLLERNAME.cmd
			;;
		*)
			echo "Cette ligne de commande n'est pas traité"
			echo $TYPECMD":"$POLLER":"$CMD 
			;;
	esac
}

# Programme
creation_pipe
lance_boucle
