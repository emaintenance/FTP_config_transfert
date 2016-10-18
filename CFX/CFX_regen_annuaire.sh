#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_regen_annuaire.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm
cfx=/usr/local/cfx

CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
#nagiosCFG=/usr/local/centreon/filesGeneration/nagiosCFG
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG

max=$(ls ${nagiosCFG} | grep -o '[0-9]*' |sort -n | tail -n 1)
nb=$(head -n -1  ${nagiosCFG}/correspondance | wc -l)

if [ $nb -ne $max ]; then
        ${cfx}/CFX_annuaire_conf.sh
		${cfx}/CFX_Update-all-Poller.sh
		${cfx}/CFX_gen_Poller-Conf.sh $max

        chown nagios.nagios * -R ${nagiosCFG}/transfert/AutoConf-Poller/
        chown nagios.nagios * -R ${nagiosCFG}/
        chmod 777 * -R ${nagiosCFG}/
fi
