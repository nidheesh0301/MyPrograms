#!/bin/bash
sid=`df -h | grep saparch  |awk '{print $6}' |cut -c8-10`
lcSid=`echo $sid | tr '[:upper:]' '[:lower:]'`
dr_ip=$1

### DR Setup ##
###copy of archive files from source to target

cd /sapdb/$sid/saparch
chmod -R 777 /sapdb/$sid/saparch
# Copy dr_SIDlog.* as SIDlog.* to source system
lists=(`ls -larth | awk '{print $9}' | sed -n "/^dr_${sid}log.*/p"`)
for sourceFile in "${lists[@]}"
do
  numberFiles=`echo $sourceFile | grep -E "^dr_$sid" | wc -l `
  if [ $numberFiles == 1 ];then
    #echo "echo $sourceFile | sed -r 's/^dr_(.+)/\1/'"
    targetFile=$(echo $sourceFile | sed -r 's/^dr_(.+)/\1/')
    #echo "su - ${lcSid}adm -c \"rsync -avz --ignore-existing /sapdb/${sid}/saparch/${sourceFile} ${lcSid}adm@${dr_ip}:/sapdb/${sid}/saparch/$targetFile\""
    su - ${lcSid}adm -c "rsync -avz --ignore-existing /sapdb/${sid}/saparch/${sourceFile} ${lcSid}adm@${dr_ip}:/sapdb/${sid}/saparch/$targetFile"
    if [ "$?" == 0 ];then
      if [ -f /sapdb/${sid}/saparch/$sourceFile ];then
        #echo "rm /sapdb/${sid}/saparch/$sourceFile"
        rm /sapdb/${sid}/saparch/$sourceFile
      fi
    fi
  fi
done