#!/usr/bin/sh
#Sishir (i351302)
#Purpose: Check the Primary and DR related Crons at Hyperscaler

host=`hostname |cut -b 1-4`

if [[ "$host" = "pc41" || "$host" = "pc47" || "$host" = "pc55" ]];
        then
                host_type="primary"
        elif [[ "$host" == "pd43" || "$host" == "pd49" || "$host" == "pd56" ]];
                then
                host_type="dr"
fi

sid=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
user="root"

check_status(){
#        file=$1
        script1=`crontab -u $user -l | grep dr_ | wc -l`
        if [ $script1 -ge 1 ];then
                value=`crontab -u $user -l | grep dr_ | cut -c1-1`
                if [ "$value" == "#" ];then
                  echo "Cron is commented "
                  crontab -u $user -l | grep dr_
                  echo " "
                else
                echo "Cron is Enabled "
                crontab -u $user -l | grep dr_
                fi
        else
         echo "Cron is not scheduled "
        fi
}

if [ $host_type == "primary" ];then
        check_status copyFILE.sh
elif [ $host_type == 'dr' ];then
        check_status RecoverLogBackupUpdated.sh
fi
