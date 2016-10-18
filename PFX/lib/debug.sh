#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# debug.sh                                        #
# Auteur :   Matthieu PERRIN (OBS)                #
# Fonction : Active, desactive, affiche le debug  #
###################################################

# ----------------------------------------------------------------------------- #
# Active le mode debug
debug_on()
{
	debug=true
}

# ----------------------------------------------------------------------------- #
debug()
{
	if [[ "$debug" ]]; then
		while [ "$1" != "" ]; do
		echo -n "$1 "
		shift
		done
		echo ""
	fi
}

# ----------------------------------------------------------------------------- #
# Desactive le mode debug
debug_off()
{
	unset debug
}
