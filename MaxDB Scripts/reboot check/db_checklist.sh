#!/bin/bash

RED='\033[0;41m'
NC='\033[0m'
GREEN='\033[0;32m'
SID=`df -h | grep saparch | awk '{print \$6}' | cut -c8-10`
path="/tmp"
sid=`echo ${SID} | tr [:upper:] [:lower:]`
temp=0


check_key()
{
        echo "Checking the keys in xuser list and it connectivity..."
        echo "Checking the keys in xuser list and it connectivity..." >> $path/output_log.txt
        count=0
        need_key=( "w" "DEFAULT" "c" )
        for y in "${need_key[@]}"
        do
                     key_v=`xuser list | grep Key | grep $y | wc -l`
                     if [[ $key_v -lt 1 ]];then
                       echo "$y key is not present in xuser list. Hence exiting..."
                       echo "$y key is not present in xuser list. Hence exiting..." >> $path/output_log.txt
                       exit 1
                     else
                          key_present=`xuser list | grep Key | awk -F ':' '{print $2}' | tr -d ' ' | tr '\n' ',' | sed 's/,$//g'`
                          if [[ $y == 'w' || $y == "DEFAULT" ]];then
                             connect_v=`sqlcli -jU $y "\s" | grep kernel | wc -l`
                             if [ $connect_v -lt 1 ];then
                                 echo "$y is not connecting. Hence exiting..."
                                 echo "$y is not connecting. Hence exiting..." >> $path/output_log.txt
                                 exit 1
                             else
                                count+=1
                             fi
                          else
                              connect_v=`dbmcli -U $y db_state | grep 'ONLINE\|OFFLINE' | wc -l`
                              if [ $connect_v -lt 1 ];then
                                 echo "$y is not connecting.Hence exiting..."
                                 echo "$y is not connecting.Hence exiting..." >> $path/output_log.txt
                                 exit 1
                              else
                                 count+=1
                              fi
                           fi
                      fi
         done
        if [ $count -ge '3' ];then
            current_keys=`xuser list | grep Key | awk -F ':' '{print $2}'| tr -d ' ' | tr '\n' ',' | sed 's/,$//g'`
            key_result="${GREEN}PASS${NC}"
        else
           current_keys=`xuser list | grep Key | awk -F ':' '{print $2}' | tr -d ' ' | tr '\n' ',' | sed 's/,$//g'`
           key_result="${RED}FAIL${NC}"
        fi


}



check_service()
{
   echo "Checking if all the services are up and running ..."
   echo "Checking if all the services are up and running ..." >> $path/output_log.txt
   temp=0
   service_array=('ICM' 'Gateway' 'Dispatcher' 'IGS Watchdog')
   for i in "${service_array[@]}"
   do
       colour=`sapcontrol -nr 00 -function GetProcessList | grep "$i" | awk -F ',' '{print $3}' | tr -d ' '`
       status1=`sapcontrol -nr 00 -function GetProcessList | grep "$i" | awk -F ',' '{print $4}' | tr -d ' '`
       if [[( "$colour" = 'GREEN' ) && ( "$status1" = 'Running' ) ]]
       then
          temp=$(($temp + 1))
       fi
   done
   if [ $temp -eq 4 ];then
       check_srv="Service Running"
       service_r="${GREEN}PASS${NC}"
   else
       check_srv="Service not Running"
       service_r="${RED}FAIL${NC}"
       echo -e "${RED}12. Please Check if all services are up and running.${NC} " >> $path/fail.txt
fi
}


check_db_availability()
{
        echo "Checking DB availability... "
        echo "Checking DB availability..." >>  $path/output_log.txt
        db_status=`dbmcli -U c db_state | tail -1`
        db_log_stat=`dbmcli -U c db_state -v | grep "Log Full" | awk '{print $4}'`
        db_db_stat=`dbmcli -U c db_state -v | grep "Database Full" | awk '{print $4}'`
        if [[ "$db_status" != "ONLINE" && "$db_log_stat" != "No" && "$db_db_stat" != "No" ]];then
                db_avial="${RED}FAIL${NC}"
                echo -e "${RED}2. Please Check the DB availability . Currently value is OFFLINE or DB log state is not set to NO or DB status is not set to NO${NC} " >> $path/fail.txt
                echo " DB is not online .Hence exiting "
                echo " DB is not online .Hence exiting " >> $path/output_log.txt
                exit 1
        else
          db_avial="${GREEN}PASS${NC}"
        fi
        db_res="$db_status,$db_log_stat,$db_db_stat"
}
check_info_state()
{
      echo "Checking the Info state..."
      echo "Checking the Info state..." >> $path/output_log.txt
     info_state=`dbmcli -U c info state | grep -i "bad indexes" | awk '{print $4}'`

      if [ "$info_state" == 0 ];then
        info_statev="${GREEN}PASS${NC}"
      else
        info_statev="${RED}FAIL${NC}"
        echo -e "${RED}3.Please check the BAD Indexes value in info state. Currently value is $info_state${NC}" >> $path/fail.txt
       fi

}

check_auto_extend()
{
   echo "Checking AUTO EXTEND Critical..."
   echo "Checking AUTO EXTEND Critical..." >> $path/output_log.txt
   autoextend_critical=`dbmcli -U c auto_extend show | head -2 | tail -1`
   if [ "$autoextend_critical" != "ON" ];then
        autoextend_critic="${RED}FAIL${NC}"
        echo -e "${RED}4. Please check the AUTO EXTEND Value . Currently value is $autoextend_critic ${NC}" >> $path/fail.txt
   else
        autoextend_critic="${GREEN}PASS${NC}"
   fi
}

check_dbm_instance()
{
        echo "Checking DBM Instance..."
        echo "Checking DBM Instance... " >> $path/output_log.txt
        dbm_version=`dbmcli -U c dbm_version | grep -i INSTANCE | awk '{print $3}'`
        if [ "$dbm_version"  != "OLTP" ];then
                echo -e "${RED}5. Please check the DBM version INSTANCE . Current value is $dbm_version ${NC}" >> $path/fail.txt
                dbm_v="${RED}FAIL${NC}"
        else
                dbm_v="${GREEN}PASS${NC}"
        fi
}
start_xserver()
{
x_server start
}

start_xserver

check_dbm_unicode()
{
        echo "Checking DBM UNICODE..."
        echo "Checking DBM UNICODE..." >> $path/output_log.txt
        dbm_unicode=`dbmcli -U c dbm_version | grep -i UNICODE | awk '{print $3}'`
        if [ "$dbm_unicode" != "YES" ];then
                echo -e "${RED}6. PLease check the DBM _version UNICODE . Current value is $dbm_unicode ${NC} " >> $path/fail.txt
                dbm_v1="${RED}FAIL${NC}"
        else
                dbm_v1="${GREEN}PASS${NC}"
        fi

}

check_db_client_version()
{
        echo "Checking the DB Client Version..."
        echo "Checking the DB Client version..." >> $path/output_log.txt
        db_v=`dbmcli -U c inst_enum | grep -w "db" | awk '{print $1}'`
        cli_v=`dbmcli -U c inst_enum | grep -w "clients" | grep $SID | awk '{print $1}'`
        num1="7.9.10.04"

        function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }

        if [[ ( ! $(version $num1) == $(version $db_v) ) || (! $(version $num1) == $(version $cli_v))]]; then
                echo -e "${RED}9. Please check the DB version and client version ${NC} " >> $path/fail.txt
                db_vr="${RED}FAIL/DB version = $db_v , Client_version = $cli_v${NC}"
        else
                db_vr="${GREEN}PASS${NC}"
        fi

}
check_maxdata_volumes()
{
     echo "Checking MAXDATA VOLUMES..."
     echo "Checking MAXDATA Volumes..." >> $path/output_log.txt
     max_data=`dbmcli -U c param_directget MAXDATAVOLUMES | tail -1 | awk '{print $2}'`
     if [ "$max_data" -eq "255" ];then
        max_datav="${GREEN}PASS${NC}"
     else
        max_datav="${RED}FAIL${NC}"
        echo -e "${RED}7. Please check the MAXDATAVOLUMES . Currently value is $max_data${NC} " >> $path/fail.txt
     fi

}

check_maxlog_volumes()
{
      echo "Checking the MAXLOG Volumes..."
      echo "Checking the MAXLOG Volumes..." >> $path/output_log.txt
      maxlog=`dbmcli -U c param_directget MAXLOGVOLUMES | tail -1 | awk '{print $2}'`
      if [ "$maxlog" -eq 2 ];then
        maxlogv="${GREEN}PASS${NC}"
      else
        maxlogv="${RED}FAIL${NC}"
        echo -e "${RED}8. PLease check the MAXLOGVolumes . Currently value is $maxlog${NC} " >> $path/fail.txt
       fi
}
check_db_analyser()
{
    echo "Checking the DB ANALYZER..."
    echo "Checking the DB ANALYZER..." >> $path/output_log.txt
    db_analyz=`dbmcli -U c dban_state | grep Analyzer | grep -w "not active" | wc -l`
    if [ "$db_analyz" == "1" ];then
        echo -e "${RED}10. Please check the DB analyzer . Current value is $db_analyz${NC} " >> $path/fail.txt
        db_analyv="${RED}FAIL${NC}"
    else
        db_analyv="${GREEN}PASS${NC}"
    fi
}


check_param_config()
{
   cd /tmp
   echo "Checking Parameter Configuration..."
   echo "Checking Parameter Configurtaion... " >> $path/output_log.txt
   pwd1=`echo '4A69666E55347573' | xxd -ps -r`
   /sapdb/$SID/db/bin/dbanalyzer -d $SID -u SUPERDBA,$pwd1 -f "/tmp/param.cfg" -o /tmp -i -c 1 -t 1,1 -n vadb$sid
   /sapdb/$SID/db/bin/dbanalyzer -d $SID -u SUPERDBA,$pwd1 -f "/tmp/param.cfg" -o /tmp -i -c 1 -t 1,1 -n vadb$sid >> $path/output_log.txt
   param="${GREEN}INFO${NC}"
}

check_xserver_state()
{
     echo "Checking XSERVER State..."
     echo "Checking Xserver state..." >> $path/output_log.txt
     check1=`ps -eaf | grep 7200 | grep -v grep | wc -l`
     check2=`ps -eaf | grep sdbgloballistener | grep -v grep | wc -l`
     if [[ ($check1 -ge 2) && ($check2 -ge 2) ]];then
           xserver_info="${GREEN}PASS${NC}"
     else
           xserver_info="${RED}FAIL${NC}"
           echo -e "${RED}13. Please check the XSERVER state. Current value is $check1 " >> $path/fail.txt
     fi
}

check_autolog_show()
{
     echo "Checking AUTOLOG SHOW..."
     echo "Checking Autolog show..." >> $path/output_log.txt
     autolog_s=`dbmcli -U c autolog_show | tail -1 | awk '{print $3}'`
     if [ "$autolog_s" == "ON" ];then
                autolog_sr="${GREEN}PASS${NC}"
     else
                autolog_sr="${RED}FAIL${NC}"
                echo -e "${RED}14. Please check the AUTOLOG_SHOW. Current value is $autolog_s " >> $path/fail.txt
     fi
}

db_checks()
{
      check_key
      check_xserver_state
      check_db_availability
      check_info_state
      check_service
      check_auto_extend
      check_dbm_instance
      check_dbm_unicode
      check_db_client_version
      check_maxdata_volumes
      check_maxlog_volumes
      check_db_analyser
      check_param_config
      check_autolog_show
}


db_checks

echo -e "|Check No | Check Name                     | Current Value              | Expected Value  | Check Result |
|1 |Check Key presence and connectivity | $current_keys            | w,DEFAULT,c     | ${key_result}
|2 |Check DB Availability               | $db_res                  | ONLINE,NO,NO    | $db_avial
|3 |Check Bad Index                     | $info_state                             | 0               | $info_statev
|3 |Check Auto Extend                   | $autoextend_critical                            | ON              | $autoextend_critic
|5 |Check DBM version Instance          | $dbm_version                          | OLTP            | $dbm_v
|6 |Check DBM version UNICODE           | $dbm_unicode                           | YES             | $dbm_v1
|7 |Check MAXDATA volumes               | $max_data                           | 255             | $max_datav
|8 |Check MAXLOG Volumes                | $maxlog                             | 2               | $maxlogv
|9 |Check DB and Client version         |DB:$db_v,Client:$cli_v  | 7.9.10.04       | $db_vr
|10|Check DB Analyser                   | $db_analyz                             |  1              | $db_analyv
|11|Check Parameter configuration       |  NA                           |  NA             | ${GREEN}INFO${NC}
|12|Check Services                      | $check_srv               | Service Running   | $service_r
|13|Check Xserver info                  | $check1                            |  >= 2            | $xserver_info
|14| Check Autolog show                 | $autolog_s                            | ON              | $autolog_sr " > /tmp/db_checklist.txt

#cat /tmp/db_checklist.txt
