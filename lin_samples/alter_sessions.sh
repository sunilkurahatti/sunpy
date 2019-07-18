#! /bin/bash

###############################################################################################################
# This script can be used to filter the affected sessions from the persistence file which is pre generated    #
# in that  environments                                                                                       #  
# Prerequisites:                                                                                              #
#  1) The persistence file for that ENVs located at                                                           # 
#    /apps/infa/${env}inf/server/infa_shared/persistent_files/per_file_$env                                   #
#     Example: If you need persistence file on c09, execute it on c09 and the persistence file would be       #
#       /apps/infa/c09inf/server/infa_shared/persistent_files/per_file_c09                                    # 
#  2) The affected session names for which the massupdate must be run should be supplied as input             #
#    The input can be comma separated list for multiple sessions                                              #
# Usage : alter_sessions.sh -e  <ENV> -s <session1,session2> -v <0|1>                                                # 
#                                                                                                             #
# Support Email: ckatta@seic.com/ujammula.seic.com                                                            #
#                                                                                                             #
###############################################################################################################

function usage {
    echo -e "Script usage: \n  alter_sessions.sh -e <ENV> -s <session1,session2,session3...> -v 0\n  Example: alter_sessions.sh -e c45 -s s_m_DS_ACCT_ETL_REF,s_m_EDB_DWS_Fee_Calc_Package_Load  -v 0\n"
    exit
}

function initialize {
    cfg_file=/apps/infa/${env}inf/etlenvbuild.cfg
    infa_home=/apps/infa/${env}inf/server/infa_shared/ExtProc/
    persistent_file_home=/apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files
    persistent_file=$persistent_file_home/per_file_$env
    filtered_per_file=$persistent_file_home/per_file_${env}_filtered
    massupdate_log_file=$persistent_file_home/massupdate_log_file.`date +'%d%m%y'`
    success_sessions=$persistent_file_home/success
    failed_sessions=$persistent_file_home/failed
 if [[ $value -eq 1 ]]
     then
     massupdate_log_file=$massupdate_log_file.reverted
     success_sessions=$success_sessions.reverted
     failed_sessions=$failed_sessions.reverted
 fi
    rm -f $filtered_per_file $success_sessions $failed_sessions 
    touch $success_sessions $failed_sessions

    if [ ! -f $persistent_file ]
    then 
        echo "Attention Required: Persitence file does not exist for $env. Checking at $persistent_file"
        exit 1;
    fi
    egrep -w $sessions $persistent_file | grep ,session, >> $filtered_per_file
}

function massupdate {
    source /apps/infa/${env}inf/.profile
    ${infa_home}/update_DB.pl -e c45 -s $sessions
    pmrep massupdate -i $filtered_per_file  -t 'session_config_property' -n 'Stop on errors' -v $value -u $massupdate_log_file
    echo "Massupdate Log: $massupdate_log_file"
}

function filter_log {
    egrep $sessions $massupdate_log_file | grep -v "will not be updated" |awk -F "," '{ if (NF == 4) print $0}' >> $success_sessions
    egrep $sessions $massupdate_log_file | awk -F "," '{ if (NF != 4) print $0}' >> $failed_sessions
    grep "will not be updated" $massupdate_log_file >> $failed_sessions
    if [[ `grep -c "cannot be fetched" $massupdate_log_file ` -gt 0 ]] 
    then
       echo "All sessions belonging to below workflows could not be updated"  >> $failed_sessions
       grep  "cannot be fetched" $massupdate_log_file | awk '{print $3}' >> $failed_sessions
    fi
    if [[ $(wc -l <$success_sessions) -gt 0 ]]; then
                echo -e "\t ** The sessions successfully updated(Stop on Errors): ** \n" ; cat  $success_sessions
    fi            
    if [[ $(wc -c <$failed_sessions) -gt 0 ]];  then
                echo -e "\t ** The sessions failed to update (Stop on Errors): **" ; cat  $failed_sessions
    fi

}


if [[ $# -lt 6 ]]
then    
    usage;
    exit 1;
fi

while getopts ":e:s:v:h" opt; do
      case $opt in
          e)
               env=$OPTARG;
               ;;
          s) 
               sessions=`echo $OPTARG | sed  s'#,#|#'g`;
               ;;
          v) 
               value=$OPTARG;
               ;;
          h)
               usage;
               exit 1
               ;;
          ?)
               echo "Invalid option: -$OPTARG; Refer usage" >&2
               usage;
               exit 1
               ;;
               esac
done

    initialize;
    massupdate;
    filter_log;
