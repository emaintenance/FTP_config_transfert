#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################

numpoller=$1

centreon_config=/etc/centreon/conf.pm
cfx=/usr/local/cfx

CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG
eMaintCFG=${CentreonDir}/filesGeneration/eMaintCFG
brokerCFG=${CentreonDir}/filesGeneration/broker

moduleXML=poller-module.xml

[ -f ${nagiosCFG}/${numpoller}/Poller-Conf ] && echo "${nagiosCFG}/${numpoller}/Poller-Conf already present" && exit 1

if [ -f ${nagiosCFG}/${numpoller}/ndomod.cfg ]; then
    pollername=$(cat ${nagiosCFG}/${numpoller}/ndomod.cfg  | grep instance_name | cut -d '=' -f 2)
    centralip=$(cat ${nagiosCFG}/${numpoller}/ndomod.cfg  | grep "output=" | cut -d '=' -f 2)
fi

	#moduleXML=$( cat $nagiosCFG/${numpoller}/centengine.cfg | grep cbmod | rev | cut -d"/" -f1 | rev)
if [ -f  ${brokerCFG}/${numpoller}/${moduleXML}  ]; then
    pollername=$(cat ${brokerCFG}/${numpoller}/${moduleXML} | grep instance_name | sed 's,<instance_name>,,g; s,</instance_name>,,g; s,CDATA,,g' | sed 's/[^a-zA-Z0-9_\-]//g' | tr -d  ' ')
    centralip=$(cat ${brokerCFG}/${numpoller}/${moduleXML} | grep host | sed 's,<host>,,g; s,</host>,,g; s,CDATA,,g' | sed 's/[^a-zA-Z0-9_\-]//g' | tr -d  ' ')
fi


echo "POLLERNAME=${pollername}" >> ${nagiosCFG}/${numpoller}/Poller-Conf
echo "CENTRALIP=${centralip}" >> ${nagiosCFG}/${numpoller}/Poller-Conf
