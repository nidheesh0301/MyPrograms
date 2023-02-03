#! /bin/sh


if [ -f /etc/rc.config ]; then

. /etc/rc.config

fi

# where to find x_server executable (global listener)

IND_PROG_DBROOT=""

if [ -f /etc/opt/sdb ]; then

IND_PROG_DBROOT=`grep '^IndepPrograms=' /etc/opt/sdb | sed 's:IndepPrograms=::g'`

else

exit 5

fi

X_SERVER=$IND_PROG_DBROOT/bin/sdbgloballistener

X_PATH=$IND_PROG_DBROOT/bin

MaxDB_BIN=$X_SERVER

test -x $MaxDB_BIN || exit 5

MaxDB_BIN=$X_PATH/dbmcli

test -x $MaxDB_BIN || exit 5

# find program fuser

FUSER=/bin/fuser

test -x $FUSER || FUSER=/sbin/fuser

test -x $FUSER || FUSER=/usr/sbin/fuser

RETVAL=1

case "$1" in

start)

echo -n "Starting MaxDB services: "

if [ ! -z "$X_SERVER" ]; then

$X_SERVER start>/dev/null 2>&1

# to enable auto start/stop XCC remove following comments

DBMCLI=$X_PATH/dbmcli

if [ ! -x $DBMCLI ]; then

echo "dbmcli not found" >&2

exit 5

fi

_o=`$DBMCLI -d XCC << __EOD__ 2>&1 > /dev/null

user_logon control,JifnU4us

db_online

__EOD__`

_test=`echo $_o | grep ERR`

if [ "$_test" = "" ]; then

echo -n " database XCC started"

else

echo "cannot start XCC : $_o" >&2

exit 7

fi

RETVAL=0

fi

touch /var/lock/subsys/maxdb

;;

stop)

echo -n "Shutting down MaxDB services: "

if [ ! -z "$X_SERVER" ]; then


# to enable auto start/stop XCC remove following comments

DBMCLI=$X_PATH/dbmcli

if [ ! -x $DBMCLI ]; then

echo "dbmcli not found" >&2

exit 5

fi

_o=`$DBMCLI -d XCC << __EOD__ 2>&1 /dev/null

user_logon control,JifnU4us

db_offline

__EOD__`

_test=`echo $_o | grep ERR`

if [ "$_test" = "" ]; then

echo -n "database XCC stopped"

else

echo "cannot stop XCC : $_o" >&2

exit 1

fi

$X_SERVER stop -all > /dev/null 2>&1

RETVAL=0

fi

rm -f /var/lock/subsys/maxdb

;;

status)

if [ ! -z "$X_PATH" ]; then

if [ -x $FUSER ]; then

_o=`$FUSER $IND_PROG_DBROOT/pgm/vserver`

if [ $? -eq 0 ]; then

echo "communication server is running"


# to enable auto start/stop XCC remove following comments


DBMCLI=$X_PATH/dbmcli

if [ ! -x $DBMCLI ]; then

echo "dbmcli not found" >&2

exit 5

fi

_o=`$DBMCLI -d XCC << __EOD__

user_logon control,JifnU4us

db_state

__EOD__`

_test=`echo $_o | grep ERR`

if [ "$_test" = "" ]; then

_state=`echo $_o | sed s/.*State\ *// | sed s/\ .*//`

echo "database XCC is $_state"

else

echo "cannot get state of XCC : $_o" >&2

fi

RETVAL=0

else

echo "communication server is not running"

RETVAL=0

fi

else

echo "status unkown - fuser not found" >&2

fi

else

echo "status unkown - x_server not found" >&2

fi

;;

restart)

$0 stop

$0 start

;;

reload)

$0 stop

$0 start

;;

*)

echo "Usage: maxdb {start|stop|status|reload|restart}"

exit 1

;;

esac

exit $RETVAL
