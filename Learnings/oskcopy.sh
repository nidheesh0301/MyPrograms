#! /usr/bin/sh
sid=$(df -h | grep saparch | awk '{print $6}' | cut -c8-10)
parent_dir="/sapdb/${sid}/saparch/nid/"
last_copied=$(tail -10 dbm.mdf | grep auto_log_recover | tail -1 | awk -F'|' '{ print $9}' | awk -F'.' '{print $2}')
echo "last copied log is: " $last_copied
cd ${parent_dir}/source/
files_list=$(ls -l | awk '{print $9}' | grep ${sid} | awk -F '.' '{print $2}')
echo "Files present in the source: " $files_list

if [ -z $(grep auto_log_recover ${parent_dir}/dbm.mdf | awk -F '|' '{print $3}' | uniq) ]; then

    echo "no auto_log_recovery happened.! proceeding with complete log copy"
    rsync -avz --ignore-existing ${parent_dir}/source/ ${parent_dir}/target/

else

    echo "auto_log_recover found proceeding with new logs copy"

    for i in $files_list; do
        if [ $i -gt $last_copied ]; then
            cp ${sid}log.$i ${parent_dir}/target/
        fi
    done
fi


currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
cd /usr/sap/CVO1/q_sysfiles/sourcelogs_${sid}
rsync -avz --ignore-existing /usr/sap/CVO1/q_sysfiles/sourcelogs_${sid}/*  /sapdb/$sid/saparch/
status=$?
cd /sapdb/$sid/saparch/
chmod 777 *
chown sdb:sdba *
echo "$currentDate ${sid} $status" >> /tmp/rsync.status