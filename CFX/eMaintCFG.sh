#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# eMaintCFG.sh
# Central File eXchange - apr 2017 - Matthieu PERRIN

eMaintCFG=/usr/local/centreon/filesGeneration/eMaintCFG
nagiosCFG=/usr/local/centreon/filesGeneration/nagiosCFG

mkdir -p ${eMaintCFG}


for d in ${nagiosCFG}/*/ ; do
    if [ -f $d/centengine.cfg ]; then
    pollerid=$(basename $d)
    mkdir -p ${eMaintCFG}/${pollerid}
    yes no |cp -i ${nagiosCFG}/${pollerid}/* ${eMaintCFG}/${pollerid}/
    #echo "$d"
        fi
done

