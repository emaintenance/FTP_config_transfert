#!/bin/bash

#Librairie de l'eMaintenance
#DEv By CTR AKKA/2013
#Module Variable Generale

# Version PFX
PATH_PFX="/usr/local/pfx"
PATH_LOG="/var/log/pfx"
#CONFNAGIOS="/etc/pfx/Poller-Conf"
#CONFRLI="/etc/pfx/Poller-Slave"

FTP_LOCAL="/home/pfx"
FTP_USER="ftp"
FTP_PASS="ftp"
HOST_CENTRAL="poller-maitre"
 
#Variable de programme
PGREP="/bin/grep"
PCAT="/bin/cat"
PCUT="/bin/cut"
PMKDIR="/bin/mkdir"
PRM="/bin/rm"
PFTP="/usr/bin/ftp"
PDATE="/bin/date"
PPS="/bin/ps"
PWC="/usr/bin/wc"
PNETSTAT="/bin/netstat"
PLN="/bin/ln"
PAWK="/bin/awk"
PSED="/bin/sed"
PKILLALL="/usr/bin/killall"
PCHMOD="/bin/chmod"
PCHOWN="/bin/chown"

#Variable de Date
DATEJ=$($PDATE +"%d")
DATEM=$($PDATE +"%m")
DATEY=$($PDATE +"%Y")
DATEARCH="$DATEM-$DATEJ-$DATEY-00"

#Variable RAMDOM
INDEX_SESSION=${RANDOM}

#Variable du FTP_Local
FTP_LOCAL_TRANSFERT="$FTP_LOCAL/transfert"
FTP_LOCAL_NAGLOG="$FTP_LOCAL_TRANSFERT/nagioslog"
FTP_LOCAL_AUTOCFG="$FTP_LOCAL_TRANSFERT/AutoConf-Poller"
FTP_LOCAL_PCK="$FTP_LOCAL_AUTOCFG/Packages"
FTP_LOCAL_EXEC="$FTP_LOCAL_AUTOCFG/exec"


#Variable du FTP distant
PACKDEPOT="/transfert/AutoConf-Poller/Packages"
PERFDEPOT="/transfert/perfnagios"
LOGDEPOT="/transfert/nagioslog"
PERF_SERVDEPOT="/transfert/perf-service"
FTP_DIST_TRANSFERT="transfert"
FTP_DIST_AUTOCFG="$FTP_DIST_TRANSFERT/AutoConf-Poller"
FTP_DIST_EXEC="$FTP_DIST_AUTOCFG/exec"
FTP_DIST_PACKAGES="$FTP_DIST_AUTOCFG/Packages"
FTP_DIST_NAGLOG="$FTP_DIST_TRANSFERT/nagioslog"

#Variable interne au poller
PATH_NAGIOS="/usr/local/nagios"
PATH_CONF="$PATH_NAGIOS/etc"
PATH_UTILS="$PATH_NAGIOS/utils"
PATH_VAR="$PATH_NAGIOS/var"
PATH_RW="$PATH_VAR/rw"
PATH_BIN="$PATH_NAGIOS/bin"
PATH_CMD="$PATH_RW/nagios.cmd"
PATH_LIB="$PATH_NAGIOS/libexec"
NAGLOG="nagios"
NAGPERF="service-perfdata"
NAGIOSLOG="$PATH_VAR/$NAGLOG.log"
NAGARCH="$PATH_VAR/archives/$NAGLOG-$DATEARCH.log"
PERFDATA="$PATH_VAR/$NAGPERF"
PERFARCH="$PATH_VAR/archives/$NAGPERF-$DATEARCH"
CONFNAGIOS="$PATH_NAGIOS/Poller-Conf"
CONFRLI="$PATH_NAGIOS/Poller-RLI"

NOM_ARCHIVE="bck_conf.tar"

#Variable du fichier de log
LOG="$(echo "$0" | $PCUT -d "." -f1).log"
