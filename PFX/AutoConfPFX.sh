#!/bin/bash
#########################################################################
# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# PFX Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP
#########################################################################
# Programme de mise a jour automatique des pollers CentOS 6

# ajout PATH_PFX
[ $(cat /etc/pfx/Var.sh | grep  PATH_PFX | wc -l) -eq 0 ] && echo "PATH_PFX=/usr/local/pfx" >> /etc/pfx/Var.sh
[ $(cat /usr/local/pfx/lib/Var.sh | grep  PATH_PFX | wc -l) -eq 0 ] && echo "PATH_PFX=/usr/local/pfx" >> /usr/local/pfx/lib/Var.sh

mkdir -p /usr/local/scripts/

# correction variable
[ $(cat /etc/pfx/Var.sh | grep "Var.sh" | wc -l) -eq 0 ] && echo ". /usr/local/nagios/libexec/Var.sh" >> /etc/pfx/Var.sh

# reset PFX
[ -f /usr/local/scripts/reset_pfx.sh ] || echo -e '#!/bin/bash\n/etc/init.d/pfx stop\nsleep 2\npkill -9 -f PFX\nsleep 1\n/etc/init.d/pfx start\n' > /usr/local/scripts/reset_pfx.sh
grep "pfx start" /etc/cron.d/eMaint.poller > /dev/null || echo "6 * * * * root pgrep pfxd > /dev/null || /etc/init.d/pfx start" >> /etc/cron.d/eMaint.poller
grep reset_pfx /etc/cron.d/eMaint.poller > /dev/null || echo "3 8 * * * root /usr/local/scripts/reset_pfx.sh > /dev/null 2>&1" >> /etc/cron.d/eMaint.poller

