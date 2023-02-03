#!/bin/bash
sidval=`df -h | grep saparch | awk '{print \$6}' | cut -c8-10`
#echo "Running on : "  $sidval
RED='\033[0;41m'
NC='\033[0m'
GREEN='\033[0;32m'
SID=$sidval
sid=`echo $SID| tr '[:upper:]' '[:lower:]'`
pwd_path="/usr/sap/$SID/home"
path="/tmp"

#####################
if [ -d $pwd_path ];then
continue
else
pwd_path="/usr/sap/${sid}/home"
fi


####################################

if [[ $SID == A* ]]; then
	SCHEMA="SAP${SID}DB"
else
	SCHEMA="SAP${SID}"
fi
echo "Application schema is $SCHEMA"


####################################


echo "Executing from ${sidval}adm"

############ input the password anc check for the connectivity ###################33

pwd1=$1

check_conn=`dbmcli -d $SID -u Control,$pwd1 db_state | grep fail | wc -l `
check_conn1=`sqlcli -d $SID -u $SCHEMA,$pwd1 "\s" | grep -i Kernel | wc -l`
check_conn2=`sqlcli -d $SID -u SUPERDBA,$pwd1 "\s" | grep -i Kernel | wc -l`
if [[ $check_conn == 0 && $check_conn1 == 1 && $check_conn2 == 1 ]];then
       echo "Connecting .Password entered is correct "
       break
else
       echo "Entered password is incorrect . Please enter the correct password "
       exit 1
fi


echo -e "\n################# Execution Logs ############"
echo -e "\n################# Execution Logs ############" > $pwd_path/output_log.txt

echo -e "\nChecking the KEYS in the XUSER and its connectivity..."
echo -e "\nChecking the KEYS in the XUSER and its connectivity..." >> $pwd_path/output_log.txt

############## Check the keys and and its connection ##############
count=0
need_key=( "w" "DEFAULT" "c" )
for y in "${need_key[@]}"
do
        key_v=`xuser list | grep Key | grep $y | wc -l`
        if [[ $key_v -lt 1 ]];then
                xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u SAPSID,$pwd1 set
        fi
        if [[ $y == 'w' || $y == "DEFAULT" ]];then
         connect_v=`sqlcli -jU $y "\s" | grep kernel | wc -l`
        else
          connect_v=`dbmcli -U $y db_state | grep 'ONLINE\|OFFLINE' | wc -l`
        fi

        if [ $connect_v != 1 ] ; then
#                echo "Key $y has Connectivity issue"
                if [ $y == 'DEFAULT' ];then
                        echo " Setting up $y key in XUSER list... "
                        echo " Setting up $y key in XUSER list... " >> $pwd_path/output_log.txt
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u $SCHEMA,$pwd1 clear
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u $SCHEMA,$pwd1 set
                        connect_v=`sqlcli -jAU $y "\s" | grep database | wc -l`
                fi
                if [[ $y == 'c' ]];then
                        echo " Setting up $y key in XUSER list... "
                        echo " Setting up $y key in XUSER list... " >> $pwd_path/output_log.txt
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u CONTROL,$pwd1 clear
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u CONTROL,$pwd1 set
                        connect_v=`dbmcli -U $y db_state | grep 'ONLINE\|OFFLINE' | wc -l`
                fi
                if [ $y == 'w' ];then
                        echo " Setting up $y key in XUSER list... "
                        echo " Setting up $y key in XUSER list... " >> $pwd_path/output_log.txt
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u SUPERDBA,$pwd1 clear
                        xuser -U $y -d $SID -n vadb$sid -S SAPR3 -u SUPERDBA,$pwd1 set
                        connect_v=`sqlcli -jAU $y "\s" | grep database | wc -l`
                fi

        fi
        if [ $connect_v != 1 ];then
                count=$((count + 1))
        fi

#       echo "Ran for $y ====================="
done
if [ $count == 0 ] ;then
       key_conn="${GREEN}PASS${NC}"
else
        echo -e "${RED}17. Following keys are not there or connectivity issue for these keys ${NC} " > $path/fail.txt
        key_conn="${RED}FAIL${NC}"

fi




######check avilabity of the system #####

db_status=`dbmcli -U c db_state | tail -1`
echo "Checking the DB status ..."
echo "Checking the DB status ..." >> $pwd_path/output_log.txt
if [ $db_status != 'ONLINE' ]; then
        dbmcli -U c db_online
        db_status=`dbmcli -U c db_state | tail -1`
fi
db_log_stat=`dbmcli -U c db_state -v | grep "Log Full" | awk '{print $4}'`
if [ $db_log_stat != 'No' ];then
        echo "Setting up the autolog on ..."
        echo "Setting up the autolog on ..." >> $pwd_path/output_log.txt
        dbmcli -U c autolog_on
        db_log_stat=`dbmcli -U c db_state -v | grep "Log Full" | awk '{print $4}'`
fi

db_db_stat=`dbmcli -U c db_state -v | grep "Database Full" | awk '{print $4}'`
if [[ "$db_status" != "ONLINE" && "$db_log_stat" != "No" && "$db_db_stat" != "No" ]];then
        db_avial="${RED}FAIL${NC}"
        echo -e "${RED}1. Please Check the DB availability . Currently value is OFFLINE or DB log state is not set to NO or DB status is not set to NO${NC} " >> `pwd`/fail.txt
        echo " DB is not online .Hence exiting "
        echo " DB is not online .Hence exiting " >> $pwd_path/output_log.txt
        exit 1
else
        db_avial="${GREEN}PASS${NC}"
fi

###########  Check the MAXDATAVOLUMENS ########
echo "Checking MAXDATAVOLUMES..."
echo "Checking MAXDATAVOLUMES..." >> $pwd_path/output_log.txt
max_data=`dbmcli -U c param_directget MAXDATAVOLUMES | tail -1 | awk '{print $2}'`
if [ "$max_data" -lt "255" ];then
        echo "Setting MAXDATAVOLUMES to 255..."
        dbmcli -U c param_put -permanent MAXDATAVOLUMES 255
        max_data=`dbmcli -U c param_directget MAXDATAVOLUMES | tail -1 | awk '{print $2}'`
fi
if [ "$max_data" -eq "255" ];then
        max_datav="${GREEN}PASS${NC}"
else
        max_datav="${RED}FAIL${NC}"
        echo -e "${RED}2. Please check the MAXDATAVOLUMES . Currently value is $max_data${NC} " >> $path/fail.txt
fi



########   Check the MAXLOG VOLUMES ###########
echo "Checking MAXLOGVOLUMES..."
echo "Checking MAXLOGVOLUMES..." >> $pwd_path/output_log.txt
maxlog=`dbmcli -U c param_directget MAXLOGVOLUMES | tail -1 | awk '{print $2}'`
if [ "$maxlog" -lt 2 ];then
        echo "Setting MAXLOGVOLUMES to 2..."
        echo "Setting MAXLOGVOLUMES to 2..." >> $pwd_path/output_log.txt
        dbmcli -U c param_put -permanent MAXLOGVOLUMES 2
        maxlog=`dbmcli -U c param_directget MAXLOGVOLUMES | tail -1 | awk '{print $2}'`
fi
if [ "$maxlog" -ge 2 ];then
        maxlogv="${GREEN}PASS${NC}"
else
        maxlogv="${RED}FAIL${NC}"
        echo -e "${RED}3. PLease check the MAXLOGVolumes . Currently value is $maxlog${NC} " >> $path/fail.txt
fi

####### Check the MAXBACKUPMEDIA ######
echo "Checking MAXBACKUPMEDIA ..."
echo "Checking MAXBACKUPMEDIA ..." >> $pwd_path/output_log.txt
maxbkp=`dbmcli -U c param_directget MAXBACKUPMEDIA | grep MAXBACKUPMEDIA | awk '{print $2}'`
if [ "$maxbkp" -lt 16 ];then
        echo "Setting up MAXBACKUPMEDIA to 16 ..."
        echo "Setting up MAXBACKUPMEDIA to 16 ..." >> $pwd_path/output_log.txt
        dbmcli -U c param_put -permanent MAXBACKUPMEDIA 16
        maxbkp=`dbmcli -U c param_directget MAXBACKUPMEDIA | grep MAXBACKUPMEDIA | awk '{print $2}'`
fi
if [ "$maxbkp" -eq 16 ];then
        maxbkpv="${GREEN}PASS${NC}"
else
        maxbkpv="${RED}FAIL${NC}"
        echo -e " ${RED}4.Please Check the MAXBACKUPMEDIA .Currently value is $maxbkpv${NC} " >> $path/fail.txt
fi

#########Checking HCHECK User ###########
echo "Checking the HCHECK user.."
echo "Checking the HCHECK user.." >> $pwd_path/output_log.txt

hcheck_operator=`dbmcli -U c user_getall | grep -i hcheck | awk '{print}'`
hcheck_dbuser=`sqlcli -jAU w "select username from users where upper(username)='HCHECK'" | grep -i hcheck | awk '{print}' | cut -c2-7`
if [[ "$hcheck_operator" = "hcheck" || "$hcheck_operator" = "HCHECK" ]] && [[ "$hcheck_dbuser" = "HCHECK" ]];then
        echo "HCHECK user is present.."
        hcheck_datav="${GREEN}PASS${NC}"
else
        echo "Please create the hcheck user in DB..!"
        hcheck_datav="${RED}FAIL${NC}"
fi

####### Check the DenyAuthentication ######
echo "Checking DenyAuthentication ..."
echo "Checking DenyAuthentication ..." >> $pwd_path/output_log.txt
denyauth=`dbmcli -U c param_getvalue DenyAuthentication | grep BASIC | awk '{print}' | cut -c1-5`
if [ "$denyauth" != "BASIC" ];then
        echo "Adding BASIC into DenyAuthentication list..."
        echo "Adding BASIC into DenyAuthentication list ..." >> $pwd_path/output_log.txt
        dbmcli -U c param_put -permanent -running DenyAuthentication BASIC,SCRAMSHA256V2
        denyauth=`dbmcli -U c param_getvalue DenyAuthentication | grep BASIC | awk '{print}' | cut -c1-5`
fi
if [ "$denyauth" == "BASIC" ];then
        denyv="${GREEN}PASS${NC}"
else
        denyv="${RED}FAIL${NC}"
        echo -e " ${RED}4.Please Check the parameter DenyAuthentication .Current value is $denyauth${NC} " >> $path/fail.txt
fi


####### Check the MAXUSERTASKS ######

echo "Checking MAXUSERTASKS..."
echo "Checking MAXUSERTASKS..." >> $pwd_path/output_log.txt
maxtasks=`dbmcli -U c param_directget MAXUSERTASKS | grep MAXUSERTASKS | awk '{print $2}'`
if [ "$maxtasks" -lt 1000 ];then
        echo "Setting MAXUSERTASKS to 1000..."
        echo "Setting MAXUSERTASKS to 1000..." >> $pwd_path/output_log.txt
        dbmcli -U c param_put -permanent MAXUSERTASKS 1000
        maxtasks=`dbmcli -U c param_directget MAXUSERTASKS | grep MAXUSERTASKS | awk '{print $2}'`
fi
if [ "$maxtasks" -eq 1000 ];then
        maxtasksv="${GREEN}PASS${NC}"
else
        maxtasksv="${RED}FAIL${NC}"
        echo -e "${RED}5.Please check the MAXUSERTASKS . Currently value is $maxtasksv ${NC}" >> $path/fail.txt

fi

######## Check the Cache_Size #########

echo "Checking Cache Size ..."
echo "Checking Cache Size ..." >> $pwd_path/output_log.txt
cache_size=`dbmcli -U c param_directget CACHE_SIZE | grep CACHE_SIZE | awk '{print $2}'`
#num1="1398786"
#if [ "$cache_size" -lt "$num1" ];then
#        echo "Setting Cache Size to 1398786..."
#        echo "Setting Cache Size to 1398786..." >> $pwd_path/output_log.txt
#        dbmcli -U c param_put -permanent CACHE_SIZE 1398786
#        cache_size=`dbmcli -U c param_directget CACHE_SIZE | grep CACHE_SIZE | awk '{print $2}'`
#fi
#if [ "$cache_size" -ge "$num1" ];then
       cache_size="${GREEN}INFO/$cache_size${NC}"
#else
#        cache_sizev="${RED}FAIL${NC}"
#        echo -e "Currently value is $cache_size " >> $path/fail.txt
#fi

##########  Check Info state ###########
echo "Checking Bad Indexes in info state..."
echo "Checking Bad Indexes in info state..." >> $pwd_path/output_log.txt
info_state=`dbmcli -U c info state | grep -i "bad indexes" | awk '{print $4}'`

if [ "$info_state" == 0 ];then
        info_statev="${GREEN}PASS${NC}"
else
        info_statev="${RED}FAIL${NC}"
        echo -e "${RED}7.Please check the BAD Indexes value in info state. Currently value is $info_state${NC}" >> $path/fail.txt
fi


################### Check AUTO EXTEND SHOW ##########
echo "Checking Auto extend ..."
echo "Checking Auto extend ..." >> $pwd_path/output_log.txt
autoextend_critical=`dbmcli -U c auto_extend show | head -2 | tail -1`
if  [ "$autoextend_critical" != "ON" ];then
        echo "Setting Auto Extend to 90..."
        echo "Setting Auto Extend to 90..." >> $pwd_path/output_log.txt
        dbmcli -U c auto_extend ON 90
        autoextend_critical=`dbmcli -U c auto_extend show | head -2 | tail -1`
fi
if [ "$autoextend_critical" != "ON" ];then
        autoextend_critic="${RED}FAIL${NC}"
        echo -e "${RED}8. Please check the AUTO EXTEND Value . Currently value is $autoextend_critic ${NC}" >> $path/fail.txt
else
        autoextend_critic="${GREEN}PASS${NC}"
fi

################### Check AUTO LOG SHOW ##########
echo "Checking Auto Log Feature..."
echo "Checking Auto Log Feature..." >> $pwd_path/output_log.txt
autolog=`dbmcli -U c autolog_show | head -2 | tail -1`
if  [ "$autolog" != "AUTOSAVE IS ON" ];then
        echo "Trying Auto Log Feature to ON..."
        echo "Trying Auto Log Feature  to ON..." >> $pwd_path/output_log.txt
        dbmcli -U c autolog_on
        autolog=`dbmcli -U c autolog_show | head -2 | tail -1`
fi
if [ "$autolog" != "AUTOSAVE IS ON" ];then
        autolog_feature="${RED}FAIL${NC}"
        echo -e "${RED}8. Please check the AUTO Log Feature and enable it.Currently $autolog_feature ${NC}" >> $path/fail.txt
else
        autolog_feature="${GREEN}PASS${NC}"
fi
###################### Check Auto Shrink ###################

echo "Checking Auto shrink ..."
echo "Checking Auto shrink ..." >> $pwd_path/output_log.txt
auto_shrink=`dbmcli -U c auto_shrink show  | head -2 | tail -1`
if [ "$auto_shrink" == "ON" ];then
        echo "Setting up Auto Shrink to OFF..."
         echo "Setting up Auto Shrink to OFF..." >> $pwd_path/output_log.txt
        dbmcli -U c auto_shrink OFF
        auto_shrink=`dbmcli -U c auto_shrink show  | head -2 | tail -1`
fi
if [ "$auto_shrink" == "ON" ];then
        echo -e "${RED}9. Please chec the Auto shrink value . Current value is $auto_shrink ${NC}" >> $path/fail.txt
        auto_shrinkv="${RED}FAIL${NC}"
else
        auto_shrinkv="${GREEN}PASS${NC}"
fi

###################DBM version Instance ##############
echo "Checking DB version Instance ..."
echo "Checking DB version Instance ..." >> $pwd_path/output_log.txt
dbm_version=`dbmcli -U c dbm_version | grep -i INSTANCE | awk '{print $3}'`
if [ "$dbm_version"  != "OLTP" ];then
        echo -e "${RED}10. Please check the DBM version INSTANCE . Current value is $dbm_version ${NC}" >> $path/fail.txt
        dbm_v="${RED}FAIL${NC}"
else
        dbm_v="${GREEN}PASS${NC}"
fi

####################MAXLOCKS Parameter Check###############################
echo "Checking MAXSQLLOCKS..."
echo "Checking MAXSQLLOCKS..." >> $pwd_path/output_log.txt
max_lock=`dbmcli -U c param_directget MAXSQLLOCKS | tail -1 | awk '{print $2}'`
if [ "$max_lock" -lt "5000000" ];then
        echo "Setting MAXSQLLOCKS to 5000000..."
        dbmcli -U c param_put -permanent MAXSQLLOCKS 5000000
        max_lock=`dbmcli -U c param_directget MAXSQLLOCKS | tail -1 | awk '{print $2}'`
fi
if [ "$max_lock" -ge "5000000" ];then
        max_lockv="${GREEN}PASS${NC}"
else
        max_lockv="${RED}FAIL${NC}"
        echo -e "${RED}2. Please check the MAXSQLLOCKS . Currently value is $max_lockv${NC} " >> `pwd`/fail.txt
fi

#############################EnableFetchReverseOptimization################
echo "Checking EnableFetchReverseOptimization ..."
echo "Checking EnableFetchReverseOptimization..." >> $pwd_path/output_log.txt
EnableFetch=`dbmcli -U c param_directget EnableFetchReverseOptimization | tail -1 | awk '{print $2}'`
if [ "$EnableFetch" == "YES" ];then
        echo "Setting EnableFetchReverseOptimization to NO..."
        dbmcli -U c param_put -permanent EnableFetchReverseOptimization NO
        EnableFetch=`dbmcli -U c param_directget EnableFetchReverseOptimization | tail -1 | awk '{print $2}'`
fi
if [ "$EnableFetch" == "NO" ];then
        EnableFetchv="${GREEN}PASS${NC}"
else
        EnableFetchv="${RED}FAIL${NC}"
        echo -e "${RED}2. Please check the EnableFetchReverseOptimization must be set as NO . Currently value is $EnableFetchv${NC} " >> `pwd`/fail.txt
fi
#############################################################################


#############DBM version Unicode ###########
echo "Checking DB version UNICODE..."
echo "Checking DB version UNICODE..."  >> $pwd_path/output_log.txt
dbm_unicode=`dbmcli -U c dbm_version | grep -i UNICODE | awk '{print $3}'`
if [ "$dbm_unicode" != "YES" ];then
        echo -e "${RED}11. PLease check the DBM _version UNICODE . Current value is $dbm_unicode ${NC} " >> $path/fail.txt
        dbm_v1="${RED}FAIL${NC}"
else
        dbm_v1="${GREEN}PASS${NC}"
fi

############# Capture Max Data and Max Log ########33
echo "Capturing MAX Data and LOG values..."
echo "Capturing MAX Data and LOG values..." >> $pwd_path/output_log.txt
max_data_kb=`dbmcli -U c info state |grep -i Max |grep -i DATA | grep -i KB | awk '{print $5}'`
max_data_pages=`dbmcli -U c info state |grep -i Max |grep -i DATA | grep -i pages | awk '{print $5}'`
log_max_KB=`dbmcli -U c  info state |grep -i Max |grep -i LOG | grep -i KB |  awk '{print $5}'`
log_max_pages=`dbmcli -U c info state |grep -i Max |grep -i LOG | grep -i pages | awk '{print $5}'`
max_data="${GREEN}INFO/MAX_LOG=$log_max_KB(KB),$log_max_pages(p), MAX_DATA=$max_data_kb(KB),$max_data_pages(p)${NC}"


################# Check DB version ###############
echo "Checking DB and client version..."
echo "Checking DB and client version..." >> $pwd_path/output_log.txt
db_v=`dbmcli -U c inst_enum | grep -w "db" | awk '{print $1}'`
cli_v=`dbmcli -U c inst_enum | grep -w "clients" | grep $SID | awk '{print $1}'`
num1="7.9.10.07"

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

if [[ ($(version $num1) > $(version $db_v) ) || ( $(version $num1) > $(version $cli_v))]]; then

                echo -e "${RED}13. Please check the DB version and client version ${NC} " >> $path/fail.txt
        db_vr="${RED}FAIL/DB version = $db_v , Client_version = $cli_v${NC}"
else
        db_vr="${GREEN}PASS${NC}"
fi


#################### Check  Database Analyzer  ##########
echo "Checking DB analyzer status..."
echo "Checking DB analyzer status..." >> $pwd_path/output_log.txt
db_analyz=`dbmcli -U c dban_state | grep Analyzer | grep -w "not active" | wc -l`
if [ "$db_analyz" == "1" ];then
        echo "Starting the DB analyzer..."
        echo "Starting the DB analyzer..." >> $pwd_path/output_log.txt
        dbmcli -U c dban_start -t 120
        db_analyz=`dbmcli -U c dban_state | grep Analyzer | grep -w "not active" | wc -l`
fi
if [ "$db_analyz" == "1" ];then
        echo -e "${RED}14. Please check the DB analyzer . Current value is $db_analyz${NC} " >> $path/fail.txt
        db_analyv="${RED}FAIL${NC}"
else
        db_analyv="${GREEN}PASS${NC}"
fi



######################3 Check the Rundirectory path ##########
echo "Checking the Rundirectory path..."
echo "Checking the Rundirectory path..." >> $pwd_path/output_log.txt
path="/sapdb/$sidval/data/wrk/$sidval"
run_path=`dbmcli -U c param_directget RUNDIRECTORY | grep RUNDIRECTORY | awk '{print $2}'`
if [ "$path" == "$run_path" ];then
        run_pathv="${GREEN}PASS${NC}"
else
        run_pathv="${RED}FAIL${NC}"
        echo -e "15. Please check the Rundirectory . Current path is $run_pathv " >> $path/fail.txt
fi

echo "Checking the Mount point in the file system..."
echo "Checking the Mount point in the file system..." >> $pwd_path/output_log.txt
#################### Check the mount points in the filesystem #####
SID=$sidval
#arry_0=(`df -h | awk '{print $6}'`)
arry_1=("/sapdb/$SID/saplog1" "/sapdb/$SID/saparch" "/sapdb/$SID/sapdata1" )

temp_arr=()
for i in "${arry_1[@]}"
do
   res=`df -h | grep $i | wc -l`
   if [ $res -lt 1 ];then
        temp_arr+=("$i")
   fi
done

if [ ${#temp_arr[@]} == 0 ];then
        file_sys="${GREEN}PASS${NC}"
else
        echo -e "${RED}16 . Following are the mount points missing in the file system ${NC}" >> $path/fail.txt
        file_sys="${RED}FAIL${NC}"
        for j in "${temp_arr[@]}"
        do
                echo "$j" >> $path/fail.txt
        done
fi

################ Parameter Configuration Check tools ##################

echo " Checking the parameters ... "
echo " Checking the parameters ... " >> $pwd_path/output_log.txt
/sapdb/$SID/db/bin/dbanalyzer -d $SID -u SUPERDBA,$pwd1 -f `pwd`/param.cfg -o /tmp -i -c 1 -t 1,1 -n vadb$sid
/sapdb/$SID/db/bin/dbanalyzer -d $SID -u SUPERDBA,$pwd1 -f `pwd`/param.cfg -o /tmp -i -c 1 -t 1,1 -n vadb$sid >> $pwd_path/output_log.txt
param="${GREEN}INFO${NC}"
###### SAR  check ##########

sar_count=`sar 2 5 | wc -l`
if [ $sar_count -gt 3 ];then
        sar_cnt="${GREEN}PASS${NC}"
else
        sar_cnt="${RED}FAIL${NC}"
fi

################ Restart the DB ################
#echo "Restarting the DB ..."
#echo "Restarting the DB ..." >> $pwd_path/output_log.txt
#dbmcli -U c db_restart
#d1_status=`dbmcli -U c db_state | tail -1`
#echo "Checking the DB status ..."
#echo "Checking the DB status ..." >> $pwd_path/output_log.txt
#if [ $d1_status != 'ONLINE' ]; then
#        dbmcli -U c db_online
#        d1_status=`dbmcli -U c db_state | tail -1`
#else
#        echo "DB is online "
#fi
db_analyz1=`dbmcli -U c dban_state | grep Analyzer | grep -w "not active" | wc -l`
if [ "$db_analyz1" == "1" ];then
        echo "Starting the DB analyzer..."
        echo "Starting the DB analyzer..." >> $pwd_path/output_log.txt
        dbmcli -U c dban_start -t 120
#        db_analyz=`dbmcli -U c dban_state | grep Analyzer | grep -w "not active" | wc -l`
fi
#################BACKUP CHECK#########################################
echo "Checking Backup configuration..."
echo "Checking Backup configuration..." >> $pwd_path/output_log.txt
cd  /sapdb/${SID}/data/wrk/${SID}/dbahist
if [ -d /sapdb/${SID}/data/wrk/${SID}/dbahist ];then
filename=`ls -larth /sapdb/${SID}/data/wrk/${SID}/dbahist |grep sda |tail -1 |awk '{print $9}'`
value=`cat $filename |tail -1 |awk '{print$4}'`
        if [[ "$value" != "Success" ]];then
        filename2=`ls -larth /sapdb/${SID}/data/wrk/${SID}/dbahist |grep sda |tail -2 |awk '{print $9}'`
        value=`cat $filename2 |tail -1 |awk '{print$4}'`
                value1="${RED}FAIL${NC}"
        else
                value1="${GREEN}PASS${NC}"
                fi
else
echo "BACKUP NOT CONFIGURED FOR THIS SYSTEM"
value1="${RED}FAIL${NC}"
fi

##################################################################
echo -e "\n"
#==== "MaxDB volume:  $max_datav"
echo "========================= SUMMARY =================================== " > $pwd_path/output.txt
echo -e "| Check Number| Check Name                                               |   Check Result         |
============================================================================================================
|     1   | Check DB Availability                                         |      $db_avial
|     2   | Check Maxdatavolumes                                          |      $max_datav
|     3   | Check MAXLOGVOLUMES                                           |      $maxlogv
|     4   | Check MAXBACKUPMEDIA                                          |      $maxbkpv
|     5   | Check MAXUSERTASKS                                            |      $maxtasksv
|     6   | Check CACHE_SIZE                                              |      $cache_size
|     7   | Check Info state                                              |      $info_statev
|     8   | Check Auto_extend                                             |      $autoextend_critic
|     9   | Check AUTOLOG FEATURE                                         |      $autolog_feature
|     10  | Check Auto_shrink                                             |      $auto_shrinkv
|     11  | Check DBM version Instance                                    |      $dbm_v
|     12  | Check DBM version UNICODE                                     |      $dbm_v1
|     13  | Display MAXDATA and MAXLOG                                    |      $max_data
|     14  | Check DB version and Client version                           |      $db_vr
|     15  | Check DB Analyzer state                                       |      $db_analyv
|     16  | Check RUNDIRECTORY path                                       |      $run_pathv
|     17  | Check File system                                             |      $file_sys
|     18  | Check KEY and connecitivity                                   |      $key_conn
|     19  | Check parameter configuration                                 |      $param
|     20  | Check MaxSQLLOCKS                                             |      $max_lockv
|     21  | Check EnableFetchReverseOptimization                          |      $EnableFetchv
|     22  | Check HCHECK user                                             |      $hcheck_datav
|     23  | Check DenyAuthentication Parameter                            |      $denyv
|     24  | Check  SAR Run                                                |      $sar_cnt          " >> $pwd_path/output.txt
