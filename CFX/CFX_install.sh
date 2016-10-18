#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# CFX Central File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# CFX_install.sh
# Central File eXchange - 30 auot 2016 - Matthieu PERRIN

echo "Add CFX scripts"
mkdir -p /usr/local/cfx
cp CFX* /usr/local/cfx/
chmod +x /usr/local/cfx/*
mkdir -p /usr/local/centreon/filesGeneration/nagiosCFG/transfert/nagioslog

echo "Disable centcore daemon"
/etc/init.d/centcore stop
chkconfig centcore off

echo "Add CFX_cmd daemon"
cp CFX_cmd /etc/init.d/CFX_cmd
chkconfig CFX_cmd on
/etc/init.d/CFX_cmd start

echo "Add CFX cron"
cat etc_cron.d_cfx.txt > /etc/cron.d/cfx

echo "Add getcmd daemon"
cp getcmd /etc/init.d/getcmd
chkconfig getcmd on
/etc/init.d/getcmd start

