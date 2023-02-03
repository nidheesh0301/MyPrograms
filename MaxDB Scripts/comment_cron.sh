#!/usr/bin/sh
#Sishir (i351302)
#Purpose: Comment the Primary and DR related Crons at Hyperscaler for meintenance

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

comment(){
        file=dr_
        script1=`crontab -u $user -l | grep dr_ | wc -l`
        if [ $script1 -ge 1 ];then
                sudo crontab -u $user -l > /tmp/mycron
                sudo cat /tmp/mycron |sed '/'$file'/s!^!#!' > /tmp/mycron1
                sudo crontab /tmp/mycron1 -u $user
                echo "Commented $1"
                crontab -u $user -l | grep dr_
        else
                echo "CRON is not present "
        fi

}

if [ $host_type == "primary" ];then
#        comment pullStatusFile.sh
         comment copyFILE.sh
elif [ $host_type == 'dr' ];then
        comment RecoverLogBackupUpdated.sh
fi
