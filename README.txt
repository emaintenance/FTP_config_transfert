# THIS IS PROVIDED "AS IS", WITHOUT ANY WARRANTY, AND WITHOUT ANY SUPPORT. 
# LICENSE : CC-BY-SA 3.0 - http://creativecommons.org/licenses/by-sa/3.0/ 
# Central File eXchange / Poller File eXchange
# Test with CentOS 6 / Centreon 2.6 / Nagios 3.5.1
# Scripts to tranfert Nagios configuration in FTP

CFX/PFX scripts allow using FTP exchange between Centreon server and pollers servers, instead of SSH.
Centreon server is FTP server and Pollers are FTP client (with SSH, Central is connecting to poller).
This design, permit to prevent all acces from outside of poller.

This is a beta version, use CFX/PFX scripts at your own risk. 

Instlation steps on Centreon.
- install FTP server 
- configure nagios-configuration-folder as FTP share folder
- disable centcore
- add CFX folders scripts
- add CFX deamon and cron

Instalation steps on Poller
- add PFX foldes scripts
- add PFX deamon and cron

Configuration
- add Poller-Conf file in nagios configuration folder on Central and Poller
- add AutoConfPFX.sh in nagios configuration folder

regenerate poller configuration in centreon

-----

Central installation :

cd /tmp
git clone https://github.com/emaintenance/FTP_config_transfert/CFX
cd CFX
bash CFX_install.sh


Poller installation : 

cd /tmp
git clone https://github.com/emaintenance/FTP_config_transfert/PFX
cd PFX
bash PFX_install.sh
