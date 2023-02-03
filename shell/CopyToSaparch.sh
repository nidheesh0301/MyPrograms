#!/bin/bash
sid=$1
LOG() {
    type_of_msg="INFO"
    if [[ $# == 1 ]]; then
        msg=$1
    elif [[ $# == 2 ]]; then
        type_of_msg=$1
        msg=$2
    else
        params=("$@")
        if [[ "INFO DEBUG WARN ERROR FATAL" =~ ${params[0]} ]]; then
            type_of_msg=${params[0]}
            params=("${params[@]:1}") # slice from index 1 to the end of the array
        fi
        msg=$(printf " %s" "${params[@]}") # Join parameters and use space as separator
    fi
    # print to the terminal if we have one
    currentDate=$(date '+%Y-%m-%d %H:%M:%S UTC%z')
    echo " [$type_of_msg] $currentDate [$0] $msg"
    echo " [$type_of_msg] $currentDate [$0] $msg" >>"/tmp/$(basename $0).log"
}

#### Function creating a step file, showing in case of rerun that this step has already been completed
function onSuccess() {
    currentDate=$(date '+%Y-%m-%d %H:%M:%S')
    echo $currentDate >$1
}

#Function to check status
function statusCheck {
    local rc=$1
    local createMsg=$2
    local msg=$3
    local logLevel="ERROR"
    if [ $createMsg -eq 0 ]; then
        if [ $rc -eq 0 ]; then
            msg="Command \"$3\" performed successfully"
        else
            msg="Command \"$3\" failed"
        fi
    fi
    if [ $rc -eq 0 ]; then
        logLevel="INFO"
        LOG $logLevel $msg
    else
        LOG $logLevel $msg
        exit $rc
    fi
}

LOG "INFO" "sid=$sid"

# Conditional copy of database logs
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
sid=$(df -h | grep saparch | awk '{print $6}' | cut -c8-10)
source="/usr/sap/CVO1/q_sysfiles/sourcelogs_${sid}/"
target="/sapdb/${sid}/saparch/"
rundir="/sapdb/${sid}/data/wrk/${sid}/"

if [ -z $(grep auto_log_recover ${rundir}/dbm.mdf | awk -F '|' '{print $3}' | uniq) ]; then

    echo "no recovery history found.! proceeding with complete log copy from CVO path"
    rsync -avz --ignore-existing ${source} ${target}
    status=$?
    cd ${target}
    chmod 777 *
    chown sdb:sdba *
    echo "$currentDate ${sid} $status" >>/tmp/rsync.status
else

    echo "auto_log_recover found proceeding with new logs copy"
    cd ${rundir}
    last_copied=$(tail -10 dbm.mdf | grep auto_log_recover | tail -1 | awk -F'|' '{ print $9}' | awk -F'.' '{print $2}')
    #echo "last copied log is: " $last_copied
    cd ${source}
    files_list=$(ls -l | awk '{print $9}' | grep ${sid} | awk -F '.' '{print $2}')
    #echo "Files present in the source: " $files_list

    for i in $files_list; do
        if [ $i -gt $last_copied ]; then
            cp ${sid}log.$i ${target}

        fi
    done
    status=$?
    cd ${target}
    chmod 777 *
    chown sdb:sdba *
    echo "$currentDate ${sid} $status" >>/tmp/rsync.status
fi

# Copy profile directory
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
LOG "INFO" "Copying /usr/sap/CVO1/q_sysfiles/sapmnt/profile to /sapmnt/${sid}/"
flock -x /tmp/profile.lock -c "rsync -avz /usr/sap/CVO1/q_sysfiles/sapmnt/profile /sapmnt/${sid}/"
status=$?
echo "$currentDate ${sid} $status" >>/tmp/rsync_profile.status

# Copy global directory
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
LOG "INFO" "Copying /usr/sap/CVO1/q_sysfiles/sapmnt/global/* to /sapmnt/${sid}/global/"
flock -x /tmp/global.lock -c "rsync -avz /usr/sap/CVO1/q_sysfiles/sapmnt/global/* /sapmnt/${sid}/global/"
status=$?
echo "$currentDate ${sid} $status" >>/tmp/rsync_global.status

# Copy audit files
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
LOG "INFO" "Copying /usr/sap/CVO1/q_sysfiles/vaci$lcSid/DVEBMGS00/log/audit_* to /usr/sap/${sid}/DVEBMGS00/log/"
numberOfFiles=$(sudo ls /usr/sap/CVO1/q_sysfiles/vaci$lcSid/DVEBMGS00/log/audit_* 2>/dev/null | wc -l)
if [[ $numberOfFiles > 0 ]]; then
    flock -x /tmp/audit.lock -c "rsync -avz /usr/sap/CVO1/q_sysfiles/vaci$lcSid/DVEBMGS00/log/audit_*  /usr/sap/${sid}/DVEBMGS00/log/"
    status=$?
    statusCheck $? 0 "sudo cp -Rp /usr/sap/CVO1/q_sysfiles/vaci$lcSid/DVEBMGS00/log/audit_*  /usr/sap/${sid}/DVEBMGS00/log/"
else
    LOG "INFO" "There are no audit_* files in folder /usr/sap/CVO1/q_sysfiles/vaci$lcSid/DVEBMGS00/log"
fi
echo "$currentDate ${sid} $status" >>/tmp/rsync_audit.status

# Copy trans directory
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
LOG "INFO" "Copying files from /usr/sap/CVO1/q_sysfiles/trans to /usr/sap/"
flock -x /tmp/trans.lock -c "rsync -av --exclude *.SAR --exclude */EPS/in/* /usr/sap/CVO1/q_sysfiles/trans /usr/sap"
status=$?
statusCheck $? 0 "flock -x /tmp/trans.lock -c \"rsync -av --exclude *.SAR --exclude */EPS/in/* /usr/sap/CVO1/q_sysfiles/trans /usr/sap\""
echo "$currentDate ${sid} $status" >>/tmp/rsync_trans.status

# Copy Customer data
currentDate=$(date '+%Y-%m-%d_%H:%M:%S UTC%z')
LOG "INFO" "Copying Customer data to /sapmnt/${sid}/"
# Find customer data folders
declare -a folders=()
# Add customer data
emptyStringPattern='^\s*$'
while IFS= read -r customData; do
    if [[ ! $customData =~ $emptyStringPattern ]]; then
        folders+=("$customData")
    fi
done <<EOT
$(find /usr/sap/CVO1/q_sysfiles/sapmnt/ -maxdepth 1 -iname customer*data -type d)
EOT
totalStatus=0
if [ ${#folders[@]} -eq 0 ]; then
    LOG "INFO" "No customer data has been found. Nothing to be copied"
else
    for arg in "${folders[@]}"; do
        LOG "INFO" "Copying \"$arg\" to /sapmnt/${sid}/"
        flock -x /tmp/customerdata.lock -c "rsync -av \"$arg\" /sapmnt/${sid}"
        cpStatus=$?
        totalStatus=$(($totalStatus + $cpStatus))
    done
fi
echo "$currentDate ${sid} $totalStatus" >>/tmp/rsync_customerdata.status
