#!/bin/bash
SID=`df -h | grep saparch | head -1 | awk '{print $6}' | cut -c8-10`
echo "Capture DB size of Source system"
DBsize=`sudo su - ${SID}adm -c "dbmcli -U c info state | grep Data | head -1 | sed -r 's/^[^0-9]+([0-9]+)$/\1/'"`
DBsizeMB=`echo $DBsize | awk '{print $1 / 1024}'`
DBsizeGB=$( expr $DBsizeMB / 1024 )
echo "DBSize(GB) : $DBsizeGB"
RDBsize=$(($DBsizeGB*75/100))
echo "Required mount space(GB) : $RDBsize"
#echo "Capture /backup_fs size on source system"
Volsize=`sudo df -h -BG | grep /backup_fs | awk '{print $4}' | sed -r 's/^([0-9]+)\w+$/\1/'`
echo "Free space in /backup_fs mount (GB) : $Volsize"

if [ $Volsize -ge $RDBsize ]; then
echo "Good to continue"
else
echo "Please increase the size of /backup_fs and continue..!"
fi
