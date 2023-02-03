#!bin/bash
host_type=$2
sid=$1
user="root"
if [ -f /tmp/replication_${sid}_${host_type}.log ];then
        rm /tmp/replication_${sid}_${host_type}.log
fi

check_status(){
        file=$1
        script1=`crontab -u $user -l | grep $1 | wc -l`
        if [ $script1 -ge 1 ];then
                value=`crontab -u $user -l | grep $1 | cut -c1-1`
                if [ "$value" == "#" ];then
                  echo "$1 is commented in cron " >> /tmp/replication_${sid}_${host_type}.log
                  crontab -u $user -l | grep $sid
                  else
                  crontab -u $user -l | grep $1  >> /tmp/replication_${sid}_${host_type}.log
#                 crontab -u $user -l | grep $sid
                fi
        else
         echo "$1 file is not scheduled in cron " >> /tmp/replication_${sid}_${host_type}.log

        fi
}

if [ $host_type == "primary" ];then
#        check_status pullStatusFile.sh
#        check_status CopyFILE.sh
        check_status copyLogBackups.sh
elif [ $host_type == 'dr' ];then
sid_l=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
sudo su - ${sid_l}adm <<EOF > /tmp/replication_${sid}_${host_type}.log 2>/dev/null
dbmcli -U c auto_log_recovery show
EOF
fi
