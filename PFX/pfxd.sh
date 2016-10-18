#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# pfxd.sh 24/12/2014
# MPE
#
#########################################################################

#source /etc/pfx/Var.sh
PATH_PFX="/usr/local/pfx"
PATH_LOG="/var/log/pfx"

continue=1

# Si CTRL+C alors continue=0
finish()
{
	continue=0
	killall -u nagios sleep
}
trap finish EXIT SIGHUP SIGINT SIGTERM

sleep $(( $RANDOM%3 ))
mkdir -p $PATH_LOG

while [ "$continue" -eq 1 ]
do
	cd $PATH_PFX
	min=$( echo -n $(/bin/date +%M) )
	sec=$( echo -n $(/bin/date +%S) )
	
	pgrep get_command > /dev/null || $PATH_PFX/PFX_get_command.sh $1 >> $PATH_LOG/PFX_get_command.log &
	
	#Si minute pair et sec inferieur a 6
	if [ $((10#$min%2)) -eq 0 ] && [ "$sec" -lt 6 ]
	then
		pgrep send_data > /dev/null || $PATH_PFX/PFX_send_data.sh $1 >> $PATH_LOG/PFX_send_data.log &
	fi
	
	if [ $min -eq 0 ] && [ "$sec" -lt 6 ]
	then
		pgrep log_rotation > /dev/null || $PATH_PFX/PFX_log_rotation.sh &
	fi
	
	sleep 5

done

date
echo "Arret de ${BASH_SOURCE[0]}"
