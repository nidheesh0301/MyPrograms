#!/bin/bash
mail=sreelakshmi.yajamaan.vijaya.krishna@sap.comm
RED='\033[0;41m'
NC='\033[0m'
GREEN='\033[0;32m'
SID=`df -h | grep saparch | awk '{print \$6}' | cut -c8-10`
sid=`echo $SID | tr [:upper:] [:lower:]`
path="/tmp"
curr_path="/tmp"
echo "Running on $SID " > $path/output_log.txt
sudo chown root:root  $path/output_log.txt $path/fail.txt
sudo chmod 777 $path/output_log.txt $path/fail.txt
DC=$2

check_os_version()
{
   echo "Checking the OS version..."
   echo "Checking the OS version..." >> $path/output_log.txt
   version=`cat /etc/SuSE-release | grep -i version | awk -F '=' '{print $2}' | xargs`
   patchlevel=`cat /etc/SuSE-release | grep -i PATCHLEVEL | awk -F '=' '{print $2}' | xargs`
   os_version=$version"."$patchlevel
   exp_os_value=$1
   if [ "$os_version" = "$exp_os_value" ];then
        check_os_result="${GREEN}PASS${NC}"
   else
        check_os_result="${RED}FAIL${NC}"
        echo "1.Please check the OS version. " >> $path/fail.txt
   fi
}

check_run_directory()
{
    echo "Checking the RUNDIRECTORY path..."
    echo "Checking the RUNDIRECTORY path..." >> $path/output_log.txt
    check_path="/sapdb/${SID}/data/wrk/${SID}"
    if [ -d $check_path ];then
        dir_exits="${GREEN}PASS${NC}"
    else
        dir_exits="${RED}FAIL${NC}"
        echo "9.Please check the RUNDIRECTORY path" >> $path/fail.txt
    fi
}

check_sar()
{
   echo "Checking sar..."
   echo "Checking sar..."  >> $path/output_log.txt
   sar_value=`sar | tail -4 | wc -l`
   #sar_value1="SAR file installed and running"
   if [ $sar_value -eq 4 ];then
       check_sar_result="${GREEN}PASS${NC}"
       sar_value1="SAR file installed and running"
   else
       check_sar_result="${RED}FAIL${NC}"
       sar_value1="Issue in sar file"
       echo "2.Please check the sar utility is installed and running" >> $path/fail.txt
   fi

}

check_files()
{
     echo "Checking the files in the saparcch,sapdata1,saplog1..."
     filecnt="0"
     path1=("/sapdb/${SID}/saparch" "/sapdb/${SID}/sapdata1" "/sapdb/${SID}/saplog1")
        for p in "${path1[@]}"
        do
               files=`ls -larth ${p} | egrep '^-' | wc -l`
               if [ $files -ge 1 ];then
                   filecnt=$(($filecnt + 1))
               fi
         done
         if [ $filecnt -eq 3 ];then
                files_r="${GREEN}PASS${NC}"
         else
                files_r="${RED}FAIL${NC}"
                echo "3.Please check the files in the saparcch,sapdata1,saplog1..." >> $path/fail.txt
         fi
}

start_xserver()
{
x_server start
}

start_xserver
kernel_version()
{
    echo "Checking the Kernel version..."
    echo "Checking the Kernel version..." >> $path/output_log.txt
    kernel_value=`uname -r`
    exp_value=$1
    if [ "$kernel_value" = "$exp_value" ];then
       kernel_v="${GREEN}PASS${NC}"
    else
       kernel_v="${RED}FAIL${NC}"
       echo "4.Please check the kernel version" >> $path/fail.txt
    fi
}

user_and_grp()
{
     echo "Checking User and Group information..."
     echo "Checking User and Group information..." >> $path/output_log.txt
     sidadm=`id ${1}adm`
     sqdadm=`id sqd${1}`
     usr_grp="${GREEN}INFO${NC}"
}

check_ownership()
{
     echo "Checking the ownership..."
     echo "Checking the ownership..." >> $path/output_log.txt
     cd /sapdb/$SID
     saparch_usr=`ls -larth | grep saparch | awk '{print $3}'`
     saparch_grp=`ls -larth | grep saparch | awk '{print $4}'`
     sapdata_usr=`ls -larth | grep sapdata1 | awk '{print $3}'`
     sapdata_grp=`ls -larth | grep sapdata1 | awk '{print $4}'`
     saplog_usr=`ls -larth | grep saplog1 | awk '{print $3}'`
     saplog_grp=`ls  -larth | grep saplog1 | awk '{print $4}'`
     per_res="SAParch usr/grp : $saparch_usr/$saparch_grp, SAPdata usr/grp : $sapdata_usr/$sapdata_grp, SAPlog usr/grp : $saplog_usr/$saplog_grp"
}


before_os_reboot()
{
    echo "--------------------------------------------------------------"

    echo -e "\nRunning the Validation before OS Reboot "
    echo -e "Running the validation before OS Reboot" >> $path/output_log.txt
    echo "--------------------------------------------------------------" >> $path/output_log.txt
    os_ver="11.4"
    check_os_version 11.4
    check_run_directory
    check_sar
    check_files
    ker_ver="4.12.14-95.80-default"
    kernel_version 4.12.14-95.80-default
    user_and_grp ${sid}
    check_ownership
    start_xserver
    echo "Checking the filesystem ..."
    df -h > /tmp/os_info.txt
}

after_os_reboot()
{
    echo "============================================================="

    echo -e "\nRunning the Validation after OS Reboot "
    echo -e "\nRunning the Validation after OS Reboot " >> $path/output_log.txt
    echo "-------------------------------------------------------------"
    echo "-------------------------------------------------------------" >> $path/output_log.txt
    os_ver="12.4"
    check_os_version 12.4
    check_sar
    check_run_directory
    check_files
    ker_ver="4.12.14-95.80-default"
    kernel_version 4.12.14-95.80-default
    user_and_grp ${sid}
    check_ownership
    start_xserver
    echo "Checking the filesystem ..."
    df -h > /tmp/os_info.txt
}


$1
echo " "
cd $curr_path

if [[ $2 == "db" || $2 == "both" ]] ;then
sudo su - ${sid}adm <<EOF
   cd $curr_path
   echo "\n-----------------------------------------------"
   echo "Running DB checks validation"
   echo "Running DB checks validation" >> $path/output_log.txt
   echo "-------------------------------------------------"
   echo "-------------------------------------------------" >> $path/output_log.txt
   sh /tmp/db_checklist.sh
EOF
if [ "$?" != "0" ];then
        exit 1
fi
fi
echo "------------- Summary of OS Checks------------- "
echo -e "|Check No | Check Name                     | Current Value                                                    | Expected Value| Check Result |
|1 |Check OS version                       |$os_version                                                              | $os_ver           |  $check_os_result
|2 |Check Sar Utility                      |$sar_value1                                    | Installed & Running| $check_sar_result
|3 |Check files in saparch,sapdata1,saplog1|$files in each folder                                        | Atleast one file must be present| $files_r
|4 |Check kernel version                   |$kernel_value                                             | $ker_ver        |   $kernel_v
|5 |Check User and Group settings (SIDADM) |$sidadm| NA        |   $usr_grp
|6 |Check User and Group settings (SQDSID) |$sqdadm| NA        |   $usr_grp
|7 |File system                            |INFO                                                               | INFO     | ${GREEN}INFO${NC}
|8 |Check the ownership of sapdb,sapdata1,saplog1 |$per_res|sdb/sdba    | ${GREEN}INFO${NC}
|9 |Check the Rundirectory path            |$check_path                                   |/sapdb/${SID}/data/wrk/${SID} | ${dir_exits}  "  > /tmp/os_checklist.txt
cat /tmp/os_checklist.txt
cat /tmp/os_checklist.txt | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g' > /tmp/os_checklist1.txt

if [[ $2 == "db" || $2 == "both" ]] ;then
echo -e "\nSummary of DB checks--------------------------"
cat /tmp/db_checklist.txt
cat /tmp/db_checklist.txt | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g' >  /tmp/db_checklist1.txt
sudo chmod 744 /tmp/db_checklist1.txt
fi
echo "------------------------End of validation checks---------------------------------"

perc=`awk -F '|' 'BEGIN{
print "<HTML><TABLE><table border=1>"}
{
printf "<tr>"
print "<td width=5%>"$2"</td><td width=25%>"$3"</td><td>"$4"</td><td width=20%>"$5"</td><td>"$6"</td>"
print "</tr>"
}
END { print"</TABLE></HTML>"} ' /tmp/os_checklist1.txt`
echo "Summary for OS checks: " > /tmp/output1_os.html
echo "$perc" >> /tmp/output1_os.html

if [[ $2 == "db" || $2 == "both" ]] ;then
perc1=`awk -F '|' 'BEGIN{
print "<HTML><TABLE><table border=1>"}
{
printf "<tr>"
print "<td width=5%>"$2"</td><td width=27%>"$3"</td><td width=16%>"$4"</td><td width=25%>"$5"</td><td>"$6"</td>"

print "</tr>"
}
END { print"</TABLE></HTML>"} ' /tmp/db_checklist1.txt`
echo "Summary for DB checks: " >> /tmp/output1_os.html
echo "$perc1" >> /tmp/output1_os.html
fi

if [ -f /tmp/fail.txt ];then
        echo -e "\n ===========Failed Check information =============="
        cat /tmp/fail.txt
 value="FAILED"
# echo "Summary" | mutt -e 'set content_type=text/html' -a /tmp/output_log.txt -s "MaxDB validation execution output for $SID :[FAILED] " -- $mail < /tmp/output1_os.html
  rm -Rf /tmp/fail.txt
else
 value="PASSED"
 #echo "Summary" | mutt -e 'set content_type=text/html'  -a /tmp/output_log.txt -s "MaxDB validation execution output for $SID :[SUCCESS] " -- $mail < /tmp/output1_os.html
fi
sudo cp $path/output_log.txt $path/${SID}_output.txt
sudo cp $path/output1_os.html $path/${SID}_output.html
# $path/os_checklist.txt $path/os_checklist_${value}.txt
#mv $path/db_checklist.txt $path/db_checklist_${value}.txt
#m $path/output_log.txt
