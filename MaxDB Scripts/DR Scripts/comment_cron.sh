#!bin/bash
host_type=$2
sid=$1
user="root"
if [ -f /tmp/replication_${sid}_${host_type}.log ];then
        rm /tmp/replication_${sid}_${host_type}.log
fi

comment(){
        file=$1
        script1=`crontab -u $user -l | grep $1 | wc -l`
        if [ $script1 -ge 1 ];then
                sudo crontab -u $user -l > mycron
                sudo cat mycron |sed '/'$file'/s!^!#!' > mycron1
                sudo crontab mycron1 -u $user
                echo "Commented $1" >> /tmp/replication_${sid}_${host_type}.log
                crontab -u $user -l | grep $sid
        else
                echo "$1 is not present in the cron " >> /tmp/replication_${sid}_${host_type}.log
        fi

}

if [ $host_type == "primary" ];then
#        comment pullStatusFile.sh
        comment copyLogBackups.sh
elif [ $host_type == 'dr' ];then
sid_l=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
sudo su - ${sid_l}adm <<EOF > /tmp/replication_${sid}_${host_type}.log 2>/dev/null
dbmcli -U c auto_log_recovery OFF FOR RESUME
dbmcli -U c auto_extend OFF
EOF
fi
