#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_LogRotate-Poller.sh
# Central File eXchange - 17 juin 2016 - Matthieu PERRIN

centreon_config=/etc/centreon/conf.pm

centlib=$(cat ${centreon_config} | grep VarLib  | cut -d'=' -f 2 |  cut -d '"' -f 2)
#log=/var/lib/centreon/log
log=${centlib}/log


ls --format=single-column ${log} | grep -o '[0-9]*' | (while read ligne
do

        if [ -f ${log}/$ligne/nagios.log ]; then
                mv ${log}/$ligne/nagios.log ${log}/$ligne/nagios-arch.log
                mkdir -p ${log}/$ligne/archives
				
				cat ${log}/$ligne/nagios-arch.log | (while read nagligne
                do
                        DATECOUR=$(echo $nagligne|/bin/cut -b 2-11)
                        DATECOUR=$(/bin/date -d @$DATECOUR +'%m-%d-%Y')
						
						touch ${log}/$ligne/archives/nagios-$DATECOUR-00.log
						echo "$nagligne" >> ${log}/$ligne/archives/nagios-$DATECOUR-00.log						
                done)
                rm -f ${log}/$ligne/nagios-arch.log
        fi

done)

