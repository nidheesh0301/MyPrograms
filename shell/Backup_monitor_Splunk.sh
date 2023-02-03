#!/usr/bin/sh
date
echo "BackupID|Backup_type|Category|Start_time|Col1|Col2|End_time|Col3|Col4|STATE|BKP_Template|Col6|Pipe|Col7|Col8|" >/sfdba/maxdb/SCRIPTS/BKPCHECK/backup_time_$$.txt
execute ()
{
input="/sfdba/maxdb/SCRIPTS/BKPCHECK/inputfile.csv"
for line in `cat $input`
do
sid=$(echo $line|awk -F'.' '{ print $1 }' | cut -c5-7)
sidc=`echo $sid | tr '[:lower:]' '[:upper:]'`

##############################################################
echo " "
echo "Execution In-progress"

ssh -t -q -o StrictHostKeyChecking=no -o ConnectTimeout=5 ${line} sudo su - ${sid}adm << 'EOF' >> /sfdba/maxdb/SCRIPTS/BKPCHECK/backup_time_$$.txt 2>/dev/null
  SID=`hostname | cut -c8-10 |  tr '[a-z]' '[A-Z]'`
  cat /sapdb/${SID}/data/wrk/${SID}/dbm.knl | sed "s/ //g" | awk -F '|' '{if($14=="0") print $ "|"}'  | grep DAT | tail -1
  cat /sapdb/${SID}/data/wrk/${SID}/dbm.knl | sed "s/ //g" | awk -F '|' '{if($14=="0") print $ "|"}'  | grep PAG | tail -1
  cat /sapdb/${SID}/data/wrk/${SID}/dbm.knl | sed "s/ //g" | awk -F '|' '{if ($14 == "0") print $ "|"}' | grep "SAVELOG" | tail -1 | sed "s/SAVELOG/SAVELOG$SID/"
EOF
done
}
execute &
wait
echo "Execution Completed"
date
NOW=$(date +"%d_%m_%Y_%HH_%MM")
cat /sfdba/maxdb/SCRIPTS/BKPCHECK/backup_time_$$.txt |grep -v 'Warning: no access to tty (Bad file descriptor).' |grep -v 'Thus no job control in this shell.' > /sfdba/maxdb/SCRIPTS/BKPCHECK/output_for_${NOW}.txt
var1=$(ls -ltr /sfdba/maxdb/SCRIPTS/BKPCHECK/output_for_*| tail -1 |awk '{print $9'})
cp $var1 /sfdba/maxdb/SCRIPTS/BKPCHECK/BACKUP_REPORT_LATEST.csv

echo -e "Backup Report Latest " | mailx -a /sfdba/maxdb/SCRIPTS/BKPCHECK/output_for_${NOW}.txt -s "MaxDB Backup check from DC41 JH"  -r noreply@successfactors.com -v yugandhar.penumuru@sap.com,b.rayapati@sap.com,sishir.kumar.sahu01@sap.com

echo "Mail sent"
find /sfdba/maxdb/SCRIPTS/BKPCHECK/output_for_* -type f -mtime +2 -delete
find /sfdba/maxdb/SCRIPTS/BKPCHECK/backup_time_* -type f -mtime +2 -delete
