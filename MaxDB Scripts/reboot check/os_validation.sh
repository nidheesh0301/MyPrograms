#!/bin/bash
echo "####################################################################################################"
echo "#                                                                                                  #"
echo "# Functionality : To perform the os and db validation before and after os_reboot                   #"
echo "# Execution : sh <file_name>                                                                       #"
echo "# Author : Sreelakshmi Yajamaan (I325063)                                                          #"
echo "#                                                                                                  #"
echo "####################################################################################################"

read -p "Enter the mail id: " mailid
#mailid=reelakshmi.yajamaan.vijaya.krishna@sap.com
if [ -z $mailid ];then
   echo "You have not entered the mailid.Hence exiting"
   exit 1
fi

RED='\033[0;41m'
NC='\033[0m'
GREEN='\033[0;32m'

if [ -d validation_output ];then
    continue
else
   mkdir validation_output
   chmod 777 validation_output
fi

if [ -f db_checklist.txt ];then
   rm db_checklist.txt
fi
if [ -f os_checklist.txt ];then
  rm os_checklist.txt
fi
echo "========================================================================="
read -p "Please enter your I/C number :     " username
if [ -z $username  ]; then
        echo "You have not entered the username"
        exit 1
fi

#echo "Enter your password "
read -sp "Enter the password : " pass
if [ -z $pass  ]; then
        echo "You have not entered the password"
        exit 1
fi


echo -e "\n"

echo "Please select the option"
echo -e "1.Run validation before the OS reboot \n2.Run Validation after the reboot\n"
read -p "Your option : " option
echo " "

echo "Please select the type of validation you want to perform : "
echo -e "1.OS Validation only \n2.DB Validation only \n3.Both the validations\n"
read -p "Your option : " valid_option

echo " "
case $valid_option in
1) valid_option_sel="os" ;;
2) valid_option_sel="db" ;;
3) valid_option_sel="both";;
esac

case $option in
1) option_sel="before_os_reboot" ;;
2) option_sel="after_os_reboot" ;;
*) echo "Invalid option "
   exit 1;;
esac
echo " | DC  | SID     |  STATUS  | " > status_output.txt

read -p "Enter the number of DCs, you want to run ( e.g, 1 )" dc_nums
i=1
dc_array=()
while [ $dc_nums -gt 0 ]
do

        read -p "Please enter the DC number ( e.g DC02)" dc_n
        dc_n=`echo $dc_n | tr '[:lower:]' '[:upper:]'`
        read -p "Enter the input file containing the servers " input_file
        check_dc=`echo "${dc_array[@]}" | grep -w ${dc_n} | wc -l`
        if [ $check_dc -le 0 ];then
                dc_array+=(${dc_n})
                cp ${input_file} ${dc_n}_input_file.txt
                dc_nums=$[$dc_nums - 1]
        else
        echo "Please provide the new DC number"
        fi
done

for dc in "${dc_array[@]}"
do
echo "----------------------------------------"
echo -e "\nRunning for the $dc\n"
for i in `cat ${dc}_input_file.txt`
do
#echo $DC

host=$i
sid=`echo ${i} | awk -F '.' '{print $1}' | cut -c5-7 | tr '[:lower:]' '[:upper:]'`
/usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null param.cfg $username@$host:/tmp > /dev/null 2>&1
/usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null validation.sh $username@$host:/tmp > /dev/null 2>&1
/usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null db_checklist.sh $username@$host:/tmp > /dev/null 2>&1
/usr/bin/sshpass -p "$pass" ssh -T -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$host /bin/bash > /dev/null 2>&1 "sudo su - root;sudo chmod 777 /tmp/param.cfg /tmp/validation.sh /tmp/db_checklist.sh;sudo chown root:root /tmp/param.cfg /tmp/validation.sh /tmp/db_checklist.sh;sh -x /tmp/validation.sh '${option_sel}' '${valid_option_sel}'"

os_output()
{
        /usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$host:/tmp/${sid}_output.txt . > /dev/null 2>&1
        cat ${sid}_output.txt
        cp ${sid}_output.txt validation_output/${sid}_output.txt
       echo " "
        echo "---------- OS Checklist--------------"
        /usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$host:/tmp/os_checklist.txt . > /dev/null 2>&1
         cat os_checklist.txt
         cp os_checklist.txt validation_output/${sid}_os_checklist.txt

}
db_output()
{
        echo " "
        echo "------------ DB checklist --------------------"
        /usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$host:/tmp/db_checklist.txt . > /dev/null 2>&1
        cat db_checklist.txt
        cp db_checklist.txt validation_output/${sid}_db_checklist.txt
}

case ${valid_option_sel} in
"os")os_output;;
"db")echo "Running for ${host}"
     db_output;;
"both")os_output
       db_output;;
esac
status_db_check=0
status_os_check=0
if [ -f os_checklist.txt ];then
        status_os_check=`cat os_checklist.txt | grep FAIL | wc -l`
fi
if [ -f db_checklist.txt ];then
        status_db_check=`cat db_checklist.txt | grep FAIL | wc -l`
fi

if [[ (${status_db_check} -eq 0 )&& (${status_os_check} -eq 0 ) ]];then
       value="PASS"
else
        value="FAIL"
fi
/usr/bin/sshpass -p "$pass" scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null $username@$host:/tmp/${sid}_output.html . > /dev/null 2>&1
cp ${sid}_output.html validation_output/${sid}_output.html

echo " | $dc | $sid    |  $value  | " >> status_output.txt
echo "---------------------------------------------------------------------------- "
done
done
cat status_output.txt
zip -qr validation_output.zip validation_output

perc1=`awk -F '|' 'BEGIN{
print "<HTML><TABLE><table border=1>"}
{
printf "<tr>"
print "<td width=5%>"$2"</td><td width=27%>"$3"</td><td width=16%>"$4"</td>"
print "</tr>"
}
END { print"</TABLE></HTML>"} ' status_output.txt`
echo "Final output summary " > status_output.html
echo "$perc1" >> status_output.html

echo "Summary" | mutt -e 'set content_type=text/html' -a validation_output.zip -s "MaxDB validation execution output " -- $mailid < status_output.html
rm -Rf validation_output.zip validation_output
