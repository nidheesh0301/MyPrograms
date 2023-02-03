#!/bin/bash
#***********************************************************************************************************#
#                                                                                                           #
# Purpose : To comment ,uncomment and check the status of cron jobs in target system                        #
# Files   : Replication_job_operations.sh (to modify the cron in the target system)                             #
#         : comment_cron.sh (to comment the cron entries based on the host type- primary/dr)                #
#         : uncomment_cron.sh (to uncomment the cron entries based on the host type -primary/dr)            #
#         : check_status.sh (to check the presence and status of the jobs based on the host_type-primary/dr #
#         (all the above files must be placed in the same location )                                        #
#InputFile: List of all servers                                                                             #
#Execution: sh Replication_job_operations.sh <inputfile>
# Version : V1.0                                                                                            #

if [ -f /automation/DATABASE/DR/outputfile.log ];then
        rm /automation/DATABASE/DR/outputfile.log
fi

run_on_target()
{
        echo "==========Running for $4==================" >> outputfile.log
#        echo "==========Running for $4=================="
        script=$1
        sid=$2
        host_type=$3
        hostname=$4
        /usr/bin/sshpass -p $pass scp -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o UserKnownHostsFile=/dev/null $script $user_name@$hostname:/tmp > /dev/null 2>&1
#/usr/bin/sshpass -p $pass ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user_name@$hostname /bin/bash > /dev/null 2>&1 << EOF
#sudo su - root << EOF1
#sudo chmod 777 /tmp/${script}
#sudo chown root:root /tmp/${script};
#sh /tmp/${script} ${sid} ${host_type};
#sudo chmod 777 /tmp/replication_${sid}_${host_type}.log
#cat /tmp/replication_${sid}_${host_type}.log
#EOF1
#EOF
/usr/bin/sshpass -p $pass ssh -t -q -o StrictHostKeyChecking=no -o ConnectTimeout=3 -o UserKnownHostsFile=/dev/null $user_name@$hostname sudo su - << EOF >> /tmp/replication_${sid}_${host_type}.log 2>/dev/null
sudo chmod 777 /tmp/${script}
sudo chown root:root /tmp/${script};
sh /tmp/${script} ${sid} ${host_type};
sudo chmod 777 /tmp/replication_${sid}_${host_type}.log
cat /tmp/replication_${sid}_${host_type}.log
EOF
#        /usr/bin/sshpass -p $pass scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $user_name@$hostname:/tmp/replication_${sid}_${host_type}.log /tmp/ > /dev/null 2>&1
        cat /tmp/replication_${sid}_${host_type}.log >> outputfile.log
        echo -e "\n" >> outputfile.log
}

# Starting here
echo -e "\n===================================================================\n"
read -p "Enter your I number : " user_name
if [ -z $user_name  ]; then
        echo "You have not entered the username "
        exit 1
fi
stty -echo
read -p "Enter your password : " pass
if [ -z $pass  ]; then
        echo "You have not entered the password\n"
        exit 1
fi
stty echo
if [ -z $1 ];then
        echo -e "\nPlease provide the text file which contain the list of server , where we need to comment/ uncomment "
        exit 1
else

   if [ -s $1 ];then
        echo " "
   else
     echo -e "\nProvided input file is empty. Please provide the text file which contain the list of server , where we need to comment/ uncomment "
     rm $1
     exit 1
   fi

fi
echo -e "\n"
echo "Please select the operation you want to perform"
echo -e "1.Check the cron jobs \n2.Comment the replication cron jobs \n3.Uncomment the replication cron jobs "
read -p "Your option : " operation

echo -e "\n"

echo "==============================================================\n"  >> outputfile.log
echo "User       : $user_name "  >> outputfile.log
echo "Operation  : $operation "  >> outputfile.log

#email="SF-CO-Payroll-DB-All@sap.com"
#email="DL_SF_CO_DB_OPERATIONS_INDIA@sap.com,DL_SF_CO_DB_OPERATIONS_US@sap.com"
email="sishir.kumar.sahu01@sap.com"

for str in `cat $1`
do
        dom1=`echo $str | awk -F '.' '{print $2}'`
        sid=`echo $str | awk -F '.' '{print $1}' | cut -c8-10 | tr '[:lower:]' '[:upper:]'`
        ##LINUX version is older one hence used '=' in if comparision
        if [[ "$dom1" = "dc041" || "$dom1" = "dc047" || "$dom1" = "dc055" ]];
        then
                host_type="primary"
        elif [[ "$dom1" == "dc043" || "$dom1" == "dc049" || "$dom1" == "dc056" ]];
                then
                                host_type="dr"
        fi
        case $operation in
        "1") run_on_target check_status.sh ${sid} ${host_type} $str;;
        "2") run_on_target comment_cron.sh ${sid} ${host_type} $str;;
        "3") run_on_target uncomment_cron.sh ${sid} ${host_type} $str;;
        *)  echo "Incorrect option,choose again "
                exit 0;;
        esac
                if [ -f /tmp/replication_${sid}_${host_type}.log ];then
                rm /tmp/replication_${sid}_${host_type}.log
                fi

done

echo " "
echo -e "---Displaying Output-- \n "
chmod 777 /automation/DATABASE/DR/outputfile.log
cat outputfile.log

echo " " | mutt -a outputfile.log -s "MaxDB Replication execution output " -- $email

#curl -F file=@outputfile.log -X GET http://10.8.48.16:8004/send_mail?data=$email
echo " "
#if [ -f $1 ];then
#        rm $1
#fi
if [ -f /home/roaming/I351302/OS_PATCHING/outputfile.log ];then
        rm /home/roaming/I351302/OS_PATCHING/outputfile.log
fi
