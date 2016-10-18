#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_Update-all-Poller.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm

CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
#nagiosCFG=/usr/local/centreon/filesGeneration/nagiosCFG
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG

 ls --format=single-column ${nagiosCFG} | grep -o '[0-9]*'  | (while read i
do

	chown nagios.nagios * -R ${nagiosCFG}/transfert/AutoConf-Poller/

	if [ -d ${nagiosCFG}/$i ]; then
			cp -f ${nagiosCFG}/transfert/AutoConf-Poller/*.sh ${nagiosCFG}/$i/
			cp -f ${nagiosCFG}/transfert/AutoConf-Poller/htpasswd.users ${nagiosCFG}/$i/
	fi

done)
