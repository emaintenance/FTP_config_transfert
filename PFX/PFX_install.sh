#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
#
# PFX_install.sh 13/01/2014
# MPE
#
#########################################################################

PATH_PFX="/usr/local/pfx"

unzip_pfx()
{
	echo "Installing PFX scripts"
	tar -zxvf PFX*.tar.gz
	rm -Rf $PATH_PFX
	mv -f pfx/ /usr/local/
	mkdir -p $PATH_PFX/{lib,log,utils,tmp}
	chmod +x $PATH_PFX/*.sh
}

install_conf()
{
	echo "Installing PFX configuration"
	mkdir -p /etc/pfx
	mv -f $PATH_PFX/lib/Var.sh /etc/pfx/	
}

install_service()
{
	echo "Installing PFX service"
	cp -f $PATH_PFX/pfx /etc/init.d/
	chmod 755 /etc/init.d/pfx
	chkconfig --level 345 pfx on
	/etc/init.d/pfx start
}

install_autoupdate()
{
	echo "Installing AutoUpdate script"
	cp -f $PATH_PFX/PFX_get_update.sh /usr/local/nagios/PFX_get_update.sh
}

add_user_pfx()
{
	echo "Add PFX user"
	id -g pfx &>/dev/null || groupadd pfx
	id -u pfx &>/dev/null || useradd pfx -s /sbin/nologin -g pfx
	mkdir -p /home/pfx
}

disable_cron()
{
	echo "Disable old cron AND install update in root"
	echo -e 'MAILTO=\"\"\n3 2 * * 1 root /etc/init.d/pfx restart\n8 * * * * root [ $(pgrep pfxd | wc -l) -eq 0 ] && /etc/init.d/pfx start\n* * * * * root [ -f /tmp/update_pfx ] && /usr/local/nagios/PFX_get_update.sh >> /var/log/pfx/PFX_get_update.log\n' > /etc/cron.d/eMaint.poller
	echo "MAILTO=\"\"" > /etc/cron.d/eMaint.relay
}

# TODO
#/etc/hosts


###################################################

#            Programme         

###################################################

echo -e "\n######  ${BASH_SOURCE[0]}  ######\n"
date

#load_libraries
#unzip_pfx
mkdir -p ${PATH_PFX}/lib
cp -f *PFX* ${PATH_PFX}/
cp -f *pfx* ${PATH_PFX}/
cp -f lib/* ${PATH_PFX}/lib/
chmod +x ${PATH_PFX}/*
install_conf
add_user_pfx
install_autoupdate
disable_cron
install_service

$PATH_PFX/PFX_AutoConf.sh
