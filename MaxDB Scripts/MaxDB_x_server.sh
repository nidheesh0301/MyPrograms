#!/bin/bash
read -p "username:" usern;
echo "enter password:";
read -s passw;
for i in `cat inventory` ;do
sshpass -p "$passw" ssh -q -o "StrictHostKeyChecking=no" $usern@$i sudo su - << 'EOF'

SERVER_NAME=$(uname -n)
MAXDB_XSERVER_FILE=" "
MAXDB_INSTANCE_FILE=" "
PWD="/home/roaming/I523058"
TARGET="/home/roaming/I523058"
SID_ENTRY=""
SID=""
SID=$(df -h | grep saparch | head -1 | awk '{print $6}' | cut -c8-10 | tr [:upper:] [:lower:])
SID_STATUS=${SID}

## Copying the file
if [[ ! -z ${SID}  ]]; then
  SID_STATUS="SID Found"
  sudo  cp ${PWD}/serverfile ${TARGET}/maxdb_server_file 2> /dev/null
  if [[ $? -eq 0 ]]; then
    MAXDB_XSERVER_FILE="MAXDB_XSERVER_FILE Copied Successfully"
  else
    MAXDB_XSERVER_FILE="MAXDB_XSERVER_FILE copy Failed"
  fi

  sudo cp ${PWD}/servicefile ${TARGET}/maxdb_service_file 2> /dev/null
  if [[ $? -eq 0 ]]; then
    MAXDB_INSTANCE_FILE="MAXDB_INSTANCE_FILE Copied Successfully"
    sudo sed -i "s/User=abcadm/User=${SID}adm/g" ${TARGET}/maxdb_service_file
    if [[ $? -eq 0 ]];then
      SID_ENTRY="SID updated in the service file successfully"
    else
      SID_ENTRY="SID update in the service file failed"
    fi

  else
    MAXDB_INSTANCE_FILE="MAXDB_INSTANCE_FILE copy Failed"
  fi

  echo "${SERVER_NAME}:${SID}-${SID_STATUS}:${MAXDB_XSERVER_FILE}:${MAXDB_INSTANCE_FILE}:${SID_ENTRY}"
else
  SID_STATUS="SID Not Found, please check if its DB server"
  echo "${SERVER_NAME}:${SID_STATUS}"
fi


EOF
done







