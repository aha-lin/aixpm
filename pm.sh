UPLOADADDRESS=$1
USER=$2
PASS=$3
PMFILENAME=$4

if [ $# -lt 4 ]
then
        echo "usage: `basename $0` serverip username password dopm.sh"
        exit 2
fi

ftp -i -n $UPLOADADDRESS <<FTPIT
user $USER $PASS
ascii
pass
cd /
hash
prompt
get $PMFILENAME $PMFILENAME
quit
FTPIT

chmod +x $PMFILENAME

./$PMFILENAME $UPLOADADDRESS