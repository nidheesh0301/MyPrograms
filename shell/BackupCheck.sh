#!/bin/sh
histfile1="/tmp/fullbkphist"
histfile2="/tmp/incbkphist"
current_date=$(date +"%Y-%m-%d")
SID=`hostname | cut -c8-10 |  tr '[a-z]' '[A-Z]'`
Fullbkp=`cat /sapdb/${SID}/data/wrk/${SID}/dbm.knl | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/,"",$14); if($14=="0") print $7 "|" $2 "|" $14}' | grep DAT | tail -1 > $histfile1`
Incbkp=`cat /sapdb/${SID}/data/wrk/${SID}/dbm.knl | awk -F '|' '{gsub(/^[ \t]+|[ \t]+$/,"",$14); if($14=="0") print $7 "|" $2 "|" $14}' | grep PAG | tail -1 > $histfile2`

#check existenace of file in /tmp

if [ ! -e $histfile1 ] || [ ! -e $histfile2 ]
then
    echo "Unable to create file in /tmp, exiting..!"
    exit 0
fi

bline1=`head -n 1 $histfile1`
bline2=`head -n 1 $histfile2`

#find reported Full Data Backup
recDateTime=`echo $bline1 | awk -F '|' '{print $1}'`
recDate=`echo $recDateTime | awk '{print $1}'`
recTime=`echo $recDateTime | awk '{print $2}'`

#find reported Incremental Backup
IncrecDateTime=`echo $bline2 | awk -F '|' '{print $1}'`
IncrecDate=`echo $IncrecDateTime | awk '{print $1}'`
IncrecTime=`echo $IncrecDateTime | awk '{print $2}'`

#check the reported backup time is within the threshold

diff_in_seconds=$(( $(date -d "$current_date" +%s) - $(date -d "$recDate" +%s) ))
diff_in_days=$((diff_in_seconds / 86400))
Incdiff_in_seconds=$(( $(date -d "$current_date" +%s) - $(date -d "$IncrecDate" +%s) ))
Incdiff_in_days=$((Incdiff_in_seconds / 86400))

#find start backup number
if [[ ! $bline1 == *"DAT_"* ]]
then
    echo "No valid Full Backup entry found in $histfile1"
elif [ $diff_in_days -gt 8 ]
then
    echo "No valid Full Backup found in last one week"
elif [ $diff_in_days -le 8 ]
then
    echo "Full backup completed successfully on $recDateTime UTC "
else
    echo "No valid Full Backup found in backup catalog"
fi

if [[ ! $bline2 == *"PAG_"* ]]
then
    echo "No valid Incremental Backup entry found in $histfile2"
elif [ $Incdiff_in_days -gt 2 ]
then
    echo "No valid Incremental Backup found in last 2 days"
elif [ $Incdiff_in_days -le 2 ]
then
    echo "Incremental backup completed successfully on $IncrecDateTime UTC "
else
    echo "No valid incremental Backup found in backup catalog"
fi

exit 0

