#!bin/bash
host_type=$2
sid=$1
user="root"



if [ -f /tmp/replication_${sid}_${host_type}.log ];then
        rm /tmp/replication_${sid}_${host_type}.log
fi

uncomment(){
        file=$1
        script1=`crontab -u $user -l | grep $1 | wc -l`
        if [ $script1 -ge 1 ];then
         value=`crontab -u $user -l | grep $1 | cut -c1-1`
         while [ "$value" == '#' ]
         do
                sudo crontab -u $user -l > mycron
                sudo cat mycron | sed  '/'$file'/s/^#//' > mycron1
                sudo crontab mycron1 -u $user
                value=`crontab -u $user -l | grep $1 | cut -c1-1`
        done
        echo "Uncommented replication jobs " >> /tmp/replication_${sid}_${host_type}.log
        crontab -u $user -l | grep $sid
        else
                echo "$1 is not present in the crontab " >> /tmp/replication_${sid}_${host_type}.log
        fi
}

if [ $host_type == "primary" ];then
         uncomment copyLogBackups.sh
elif [ $host_type == 'dr' ];then
sid_l=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
sudo su - ${sid_l}adm <<EOF > /tmp/replication_${sid}_${host_type}.log 2>/dev/null
x_server start
dbmcli -U c db_admin
dbmcli -U c auto_log_recovery ON auto_log_recover with DELETE except 50
dbmcli -U c auto_extend ON 90
EOF
fi
