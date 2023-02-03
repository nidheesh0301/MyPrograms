#!/bin/bash
sid=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
sid_l=`echo $sid | tr '[:upper:]' '[:lower:]'`
dr_ip=$1
date=$(date '+%Y-%m-%d %H:%M:%S')
### DR Setup ##

#checking the connectivity to DR site

if      nc -z -w 30 -v $1 22; then
        echo "connectivity check successful;proceeding with rsync"
else
        echo "target server is not reachable; exiting the copy job ${date}"  >> /tmp/${sid}_DR_Status.log
        exit
fi

###copy of archive files from source to target

cd /sapdb/$sid/saparch
chmod -R 777 /sapdb/$sid/saparch
lists=(`ls -larth | grep -v dr | awk '{print $9}'`)
for l in "${lists[@]}"
do
  l1=`echo $l | grep -E "^$sid" | wc -l `
  if [ $l1 == 1 ];then
        su - ${sid_l}adm <<EOF
             rsync -avz --ignore-existing /sapdb/${sid}/saparch/${l} ${sid_l}adm@${dr_ip}:/sapdb/${sid}/saparch
EOF
   if [ "$?" == 0 ];then
     if [ -f /sapdb/${sid}/saparch/dr_${l} ];then
        rm /sapdb/${sid}/saparch/dr_${l}
      fi
    fi
 fi
done
