#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_reception_nagios.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm

#PATH_CENTLIB=/var/lib/centreon
PATH_CENTLIB=$(cat ${centreon_config} | grep VarLib  | cut -d'=' -f 2 |  cut -d '"' -f 2)
CentreonDir=$(cat ${centreon_config} | grep CentreonDir | cut -d'=' -f 2 |  cut -d '"' -f 2)
#log=/var/lib/centreon/log
log=${PATH_CENTLIB}/log
#nagiosCFG=/usr/local/centreon/filesGeneration/nagiosCFG
nagiosCFG=${CentreonDir}/filesGeneration/nagiosCFG
#PATH_VAR=/usr/local/nagios/var
#PATH_VAR=$(cat ${nagiosCFG}/1/nagios.cfg | grep "service_perfdata_file=" | cut -d "=" -f 2 | sed "s,/service-perfdata,,g")
PATH_VAR=/usr/local/nagios/var


for FILE1 in $(ls ${nagiosCFG}/transfert/nagioslog/nagios.*)
do

        DEPOT=$(ls $FILE1 | awk -F "." '{print $2}')
        mkdir -p $PATH_CENTLIB/log/$DEPOT
        /bin/cat $FILE1 >> $PATH_CENTLIB/log/$DEPOT/nagios.log

        if [ -f $PATH_CENTLIB/log/$DEPOT/nagios.log ]; then
                 rm -f $FILE1
        #else
        fi

done


for FILE1 in $(ls ${nagiosCFG}/transfert/nagioslog/service-perfdata.*)
do

        DEPOT=$(ls $FILE1 | awk -F "." '{print $2}')
        mkdir -p $PATH_CENTLIB/perfdata/$DEPOT
        /bin/sed -e "s/, / /g" $FILE1 >> $PATH_CENTLIB/perfdata/$DEPOT/service-perfdata
        /bin/sed -e "s/, / /g" $FILE1 >> $PATH_VAR/service-perfdata
chmod 777 $PATH_VAR/service-perfdata

        if [ -f $PATH_CENTLIB/perfdata/$DEPOT/service-perfdata ]; then
                rm -f $FILE1
        fi
done

exit
