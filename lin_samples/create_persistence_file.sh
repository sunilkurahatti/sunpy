#! /bin/bash

###############################################################################################################
# This script can be used to create the persistence file for all the environments                             #  
# Prerequisites:                                                                                              #
#  1) The SQL query to generate the persistence file must exist in all the required ENVs                      # 
#     where the persistence file is expected                                                                  #
#  2) This script should be executed on the same machine as that of the env                                   #
#     Example: If you need persistence file on c09, execute it on c09 and the persistence file would be       #
#       /apps/infa/c09inf/server/infa_shared/persistent_files/per_file_c09                                    # 
# Usage : create_persistence_file.sh -e  <ENV>                                                                # 
#                                                                                                             #
# Support Email: ckatta@seic.com/ujammula.seic.com                                                            #
#                                                                                                             #
###############################################################################################################

function usage {
    echo -e "Script usage: \n  create_persistence_file.sh -e <ENV> \n  Example: create_persistence_file.sh -e c45 \n"
    exit
}

function initialize {
    cfg_file=/apps/infa/${env}inf/etlenvbuild.cfg
    persistent_file=/apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files/per_file_$env
    rm -f /apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files/per_file_log_*
    log=/apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files/per_file_log_${env}.$$
    mkdir -p /apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files
    if [[ $? -ne 0 ]]
    then
         echo -e "\n Attention Required:Could not create the directory to hold the persistence file i.e /apps/infa/${env}inf/server/infa_shared/ExtProc/persistent_files \n Please check the permissions"
         exit 1;
    fi

    query=stop_on_errors
    #query=StoponErrors
    query=stoponerrors
    passwd=`awk -F = '$0 ~ /domain_db_pass/  {print tolower($2)}' $cfg_file`
    if [[ $? -ne 0 ]]
    then 
        echo -e "\n Attention Required: Either the ENV file does not exist or the password does not exist in the ENV file"
       exit 1;
    fi

    gen_persistence $env $passwd
}

function gen_persistence {
    source /apps/infa/${env}inf/.profile
    pmrep connect -r ${env}_rep -d ${env}_infdmn -n Administrator -x $passwd | tee -a $log 2>&1
    pmrep executequery -q $query -u $persistent_file | tee -a $log 2>&1 

    if [[ ${PIPESTATUS[0]} -ne 0 ]]
    then 
        echo -e "\n Attention Required: Creation of Persitence file failed for $env. Please check the logs at $log"
        exit 1;
    fi
}

if [[ $# -le 0 ]]
then    
    usage;
    exit 1;
fi

while getopts ":e:h" opt; do
      case $opt in
          e)
               env=$OPTARG;
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
