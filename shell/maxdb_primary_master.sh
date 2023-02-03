#!/bin/bash
mail="SF-CO-Payroll-DB-All@sap.com,sf_ecpay_cloudops@sap.com"
present_path=`pwd`
#if [ -z $1 ];then
#        echo "Please enter the mailid of the executor"
#        exit 1
#fi
SID=`df -h | grep saparch | awk '{print \$6}' | cut -c8-10`
RED='\033[0;41m'
NC='\033[0m'
GREEN='\033[0;32m'
sid=`echo $SID | tr '[:upper:]' '[:lower:]'`

count=0
for (( count=0; $count < 3;));
do
        echo "Enter the password for Control user "
        read -s pass
        if [ -z $pass ];then
                echo " Password is empty. Please enter the password..."
        else
                echo "Connecting ..."
                break
        fi
count=$((count+1))
done
if [ -z $pass ];then
        echo "You have exceeded the maximum 3 limit(s).Hence exiting ... "
        exit 1
fi


su - "sqd"$sid <<\EOF
        echo "Connectivity to sqd<sid> is fine"
EOF
su - $sid"adm" <<EOF
cd $present_path
sh validation_maxdb_ADS_sid.sh $pass
EOF
if [ "$?" != "0" ];then
        exit 1
fi


#################################Checking if directory exists##########
path="/usr/sap/${SID}/home"
if [ -d $path ];then
 :
else
path="/usr/sap/${sid}/home"
fi
###########################################


cd /sapdb/$SID
echo "Checking the ownership of sapdb,sapdata1,saplog1..." >> $path/output_log.txt
chown sdb:sdba saparch
chown sdb:sdba saplog1
chown sdb:sdba sapdata1
saparch_usr=`ls -larth | grep saparch | awk '{print $3}'`
saparch_grp=`ls -larth | grep saparch | awk '{print $4}'`
sapdata_usr=`ls -larth | grep sapdata1 | awk '{print $3}'`
sapdata_grp=`ls -larth | grep sapdata1 | awk '{print $4}'`
saplog_usr=`ls -larth | grep saplog1 | awk '{print $3}'`
saplog_grp=`ls  -larth | grep saplog1 | awk '{print $4}'`
if [[ $saparch_usr == "sdb" && $sapdata_usr == "sdb" && $saplog_usr == "sdb" && $saparch_grp == "sdba" &&  $sapdata_grp == "sdba" && $saplog_grp == "sdba" ]];then
        per_res="${GREEN}PASS${NC}"
else
        per_res="${RED}FAIL${NC}"
fi
echo -e "|     23  | Check the ownership of sapdb,sapdata1,saplog1                 |      $per_res " >> $path/output.txt
echo "=====================END of checklist ================" >> $path/output.txt

cat $path/output.txt
cat $path/output.txt | sed 's/\x1B\[[0-9;]\+[A-Za-z]//g' >  $path/output1.txt

#############echo " Formating for the tabular view ###
perc=`awk -F '|' 'BEGIN{
print "<HTML><TABLE><table border=1>"}
{
printf "<tr>"
print "<td width=5%>"$2"</td><td width=32%>"$3"</td>"
bgcolor="#ffffff"
printf "<td bgcolor="bgcolor" width=40%>%s</td>",$4
print "</tr>"
}
END { print"</TABLE></HTML>"} ' $path/output1.txt`
echo "Summary : " > $path/output1.html
echo "$perc" >> $path/output1.html
#sed -i "s/failure/<font color="red">FAIL<\/font>/g;s/success/<font color="green">PASS<\/font>/g" output1.html

if [ -f /tmp/fail.txt ];then
                echo -e "\n ===========Failed Check information =============="
        cat /tmp/fail.txt

echo "Summary" | mutt -e 'set content_type=text/html' -s "MaxDB validation execution output for $SID :[FAILED] " -a $path/output_log.txt -a /tmp/fail.txt -- $mail < $path/output1.html
rm -Rf /tmp/fail.txt
else
echo "Summary" | mutt -e 'set content_type=text/html' -s "MaxDB validation execution output for $SID :[SUCCESS] " -a $path/output_log.txt -- $mail < $path/output1.html
fi
#echo " " | mutt -e 'set content_type=text/html' -s "MaxDB Validation execution output " $mail < $path/output1.txt

rm -Rf  $path/output.txt
