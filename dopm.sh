#!/bin/ksh
# Input: 
#       upload address 
# 

LANG=C
UPLOADADDRESS=$1
MT=`lsattr -El sys0 |grep modelname|awk '{print $2}'|cut -c 5-12`
SN=`lsattr -El sys0 |grep systemid|awk '{print $2}'|cut -c 7-13`
HOSTNAME=`hostname`
OUTPUTDIRECTORY=/tmp/pm/$HOSTNAME.$MT.$SN
OUTPUTFILE=$OUTPUTDIRECTORY/$HOSTNAME.$MT.$SN.log

if [ ! -d $OUTPUTDIRECTORY ]
then 
	/usr/bin/mkdir -p $OUTPUTDIRECTORY
fi

if [ ! -f $OUTPUTFILE ] 
then 
	touch $OUTPUTFILE
fi
echo "hostname:" `hostname` |tee  $OUTPUTFILE
echo Machine Type: $MT , S/N: $SN |tee -a  $OUTPUTFILE
date |tee -a  $OUTPUTFILE
uptime | tee -a $OUTPUTFILE
echo "Processor Number: " `lsdev -Cc processor | wc -l` | tee -a $OUTPUTFILE
echo "Memory size(Good/Total): " `lsattr -El mem0 | awk '/^goodsize/ {print $2}'` " / " `lsattr -El mem0 | awk '/^size/ {print $2}'` | tee -a $OUTPUTFILE
prtconf -ckLms >> $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking system error log.... Check errpt.out" |tee -a $OUTPUTFILE
errpt -s `TZ=BEIST+2400; date +%m%d%H%M%y` 
errpt -a > $OUTPUTDIRECTORY/errpt.out
cp -p /var/adm/ras/errlog $OUTPUTDIRECTORY/errlog
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking file system ...." |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
lsfs
df -k |tee -a $OUTPUTFILE
for i in `df -k |grep "/"|awk '{print $3}'|grep -v "-"` 
do
	if [ $i -lt 10240 ] 
	then 
	FSNAME=`df -k |grep $i|awk '{print $7}` 
	echo Availible space of $FSNAME is less then 10M , pls check.
	fi 
done 
echo "checking staled lv " |tee -a $OUTPUTFILE
lsvg -o |lsvg -il |grep stale  |tee -a  $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking rootvg mirror ...." |tee -a $OUTPUTFILE
lsvg -l rootvg |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking bootlist ...." |tee -a $OUTPUTFILE
bootlist -m normal -o |tee -a $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking system paging space...." |tee -a $OUTPUTFILE
lsps -a |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking network status...." |tee -a $OUTPUTFILE 
netstat -rn |tee -a $OUTPUTFILE
odmget CuAt | grep -p route | tee -a $OUTPUTFILE
netstat -in |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking dump status...." |tee -a $OUTPUTFILE 
sysdumpdev -l |tee -a $OUTPUTFILE
sysdumpdev -L |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  AIO status...." |tee -a $OUTPUTFILE 
lsattr -El aio0 |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  sys0 attributs ...." |tee -a $OUTPUTFILE 
lsattr -El sys0 | egrep "maxuproc|minpout|maxpout|cpuguard"
lsattr -El sys0 >> $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  vmo attributs ...." |tee -a $OUTPUTFILE 
vmo -a | grep perm | tee -a $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  syncd status...." |tee -a $OUTPUTFILE 
ps -ef |grep syncd |tee -a  $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  pty attributs ...." |tee -a $OUTPUTFILE
lsattr -El pty0 |tee -a $OUTPUTFILE

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking  errdemon/srcmstr status...." |tee -a $OUTPUTFILE 
ps -ef |grep "/usr/lib/errdemon"|grep -v grep |tee -a $OUTPUTFILE
ps -ef |grep "/usr/sbin/srcmstr"|grep -v grep |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking ML status(oslevel)...." |tee -a $OUTPUTFILE 
oslevel -r | tee -a $OUTPUTFILE
oslevel -s 2> /dev/null | tee -a $OUTPUTFILE
instfix -i |grep ML |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking firmware status...." |tee -a $OUTPUTFILE 
lsmcode |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking hacmp status...." |tee -a $OUTPUTFILE 
/usr/es/sbin/cluster/utilities/cldump 2>&1 |tee -a $OUTPUTFILE 
ls -l /tmp/hacmp.out* |tee -a $OUTPUTFILE
ls -l /var/hacmp/log/hacmp.out* |tee -a $OUTPUTFILE
cp -p /tmp/hacmp.out $OUTPUTDIRECTORY/tmp_hacmp.out
cp -p /var/hacmp/log/hacmp.out $OUTPUTDIRECTORY/var_hacmp.out
cp -p /var/hacmp/clverify/clverify.log $OUTPUTDIRECTORY/clverify.log
tail -800 /usr/es/adm/cluster.log > $OUTPUTDIRECTORY/cluster.log
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking mail , see maillog...." |tee -a $OUTPUTFILE
ls -l /var/spool/mail/* |tee -a $OUTPUTFILE
tail -50 /var/spool/mail/root |tee -a $OUTPUTFILE
tail -1000 /var/spool/mail/root > $OUTPUTDIRECTORY/maillog

echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking locale setting...." |tee -a $OUTPUTFILE
locale -a |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "checking consolelog , see consolelog ...." |tee -a $OUTPUTFILE
alog -ot console > $OUTPUTDIRECTORY/consolelog
alog -ot console | tail -40 |tee -a $OUTPUTFILE
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering lscfg -vp ...." |tee -a $OUTPUTFILE
lscfg -vp > $OUTPUTDIRECTORY/lscfg-vp
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering lsslot -c pci ...." |tee -a $OUTPUTFILE
lsslot -c pci > $OUTPUTDIRECTORY/lsslot-pci
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering lsdev -C ...." |tee -a $OUTPUTFILE
lsdev -C > $OUTPUTDIRECTORY/lsdev-C
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering lspv ...." |tee -a $OUTPUTFILE
lspv > $OUTPUTDIRECTORY/lspv
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering lslpp,instfix & emgr ...." |tee -a $OUTPUTFILE
lslpp -al > $OUTPUTDIRECTORY/lslpp-al
instfix -i > $OUTPUTDIRECTORY/instfix-i
emgr -l > $OUTPUTDIRECTORY/emgr-l
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "copying /etc/hosts, .rhosts, .profile, ulimits, crontab, /etc/security/user, /etc/security/login.cfg ...." |tee -a $OUTPUTFILE
cp -p /etc/hosts $OUTPUTDIRECTORY/hosts
cp -p /.rhosts $OUTPUTDIRECTORY/dotrhosts
cp -p /.profile $OUTPUTDIRECTORY/dotprofile
cp -p /etc/security/user $OUTPUTDIRECTORY/security_user
cp -p /etc/security/login.cfg $OUTPUTDIRECTORY/security_login.cfg
crontab -l > $OUTPUTDIRECTORY/root_cron
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "gathering ps information ...." | tee -a $OUTPUTFILE
ps -ef > $OUTPUTDIRECTORY/ps-ef
ps auxw > $OUTPUTDIRECTORY/psaux
echo "-------------------------------------------------" |tee -a $OUTPUTFILE
echo "Packing files...." 
cd $OUTPUTDIRECTORY
cd ..
tar -cvf $OUTPUTDIRECTORY.tar `basename $OUTPUTDIRECTORY`
compress -f $OUTPUTDIRECTORY.tar

ftp -i -n $UPLOADADDRESS <<FTPIT
user upload upload123 
bin
pass
cd /pm
hash
prompt
put $OUTPUTDIRECTORY.tar.Z  `basename $OUTPUTDIRECTORY.tar.Z`
quit
FTPIT
