#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_get_command.sh 23/12/2014
# MPE
#
#########################################################################


#Initialisation des Libs Variable PFX
load_libraries()
{
	source /etc/pfx/Var.sh
	source $PATH_PFX/lib/lib
}


load_libraries

PATH_LOG="/var/log/pfx"

rotation_log_dir