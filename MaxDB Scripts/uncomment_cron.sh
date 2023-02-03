#!/usr/bin/sh
#Sishir (i351302)
#Purpose: Uncomment the Primary and DR related Crons at Hyperscaler

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

uncomment(){
        file=dr_
        script1=`crontab -u $user -l | grep dr_ | wc -l`
        if [ $script1 -ge 1 ];then
         value=`crontab -u $user -l | grep dr_ | cut -c1-1`
         while [ "$value" == '#' ]
         do
                sudo crontab -u $user -l > /tmp/mycron
                sudo cat /tmp/mycron | sed  '/'$file'/s/^#//' > /tmp/mycron1
                sudo crontab /tmp/mycron1 -u $user
                value=`crontab -u $user -l | grep dr_ | cut -c1-1`
        done
        echo "Uncommented replication jobs "
        crontab -u $user -l | grep dr_
        else
                echo "CRON is not present "
        fi
}

if [ $host_type == "primary" ];then
        crontab -u $user -l > /tmp/mycron
#        grep -Fq "15,45 * * * * /sapdb/$sid/dr_master/copyFILE.sh" /tmp/mycron
        crontab -u $user /tmp/mycron

#        uncomment pullStatusFile.sh
         uncomment copyFILE.sh
elif [ $host_type == 'dr' ];then
        crontab -u $user -l > /tmp/mycron
#        grep -Fq "*/30 * * * * /sapdb/$sid/dr_standby/RecoverLogBackupUpdated.sh" /tmp/mycron || echo "*/30 * * * * /sapdb/$sid/dr_standby/RecoverLogBackupUpdated.sh" >> /tmp/mycron
        crontab -u $user /tmp/mycron

        uncomment RecoverLogBackupUpdated.sh
fi
