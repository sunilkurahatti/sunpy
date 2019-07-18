#!/usr/bin/perl -w
use strict;
use Storable;
use File::Copy;
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>
#
#   Name:         startetlWorkflow.sh
#   Description:  Run a named workflow in a named folder and retrieve all
#                 related log output and redirect it to sysout. 
#
#    Usage:         startetlWorkflow.sh 
#
#  Revision:
#     24-Dec-2008    LM      		Original version 
#
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>



#------------------------------------------------------------------------------
# Retrieve the arguments passed to the script and basic validation.
#
$ENV{LC_ALL}="C";
my %args;
foreach (@ARGV) 
  {
    m/(\w+)=([\S\w\s,\.]+)/;
    $args{lc($1)} = $2;
	#print "$1\t$2\n";
  }

my $context= $args{'context'} || die "ERROR: context is mandatory \n";
my $batch_id=uc($args{'batch'}) || die "ERROR:  batch is mandatory \n";
my $folder=$args{'folder'} || die "ERROR: folder is mandatory \n";
my $workflow=$args{'workflow'} || die "ERROR: workflow is mandatory \n";
my $businessdayonly;$businessdayonly=$args{'businessdayonly'} or $businessdayonly = "N";
my $checkrejectfile;$checkrejectfile=$args{'checkrejectfile'} or $checkrejectfile = "N";
my $startfrom;$startfrom=$args{'startfrom'} or $startfrom = "N";
my $runflag;my $po_id;
my $pc_batch= $args{'pc_batch'} || die "ERROR: pc_batch is mandatory \n";
my $stmt_reserve_id=$args{'stmt_reserve_id'};

if ( defined $ENV{'DOMAIN_NAME'} && defined $ENV{'NODE_NAME'} && defined $ENV{'INT_SVC'} && $ENV{'REP_SVC'} && $ENV{'PMRootDir'})
{
print " \nTrying to start the Workflow:$workflow in Repository:$ENV{'REP_SVC'} using Integration Service : $ENV{'INT_SVC'} \n\n";
}
else
{
die "ERROR : .profile is not set properly for the user. Please run/set the .profile /n";
}

my $template_paramfile;$template_paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . ".par";
my $errorlog; $errorlog  = $args{'p_workflow'} or  $errorlog = $workflow;
my $paramfile;my $runinstance; my $param_archive_loc;

if ( $context eq "I" )
{
$po_id=0;
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_i_" . $batch_id . ".par";
$param_archive_loc=$ENV{'NAS'} . "/infodel/archive/monthly/" . $workflow . "_i_" . $batch_id . ".par";
$runinstance = $batch_id;
}
elsif ( $context eq "P" )
{
$po_id= $args{'po_id'} || die "ERROR: po_id is mandatory in the context of PO\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $stmt_reserve_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$param_archive_loc=$ENV{'NAS'} . "/infodel/archive/monthly/" . $workflow . "_" . $stmt_reserve_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$runinstance = $stmt_reserve_id . "_" . $batch_id . "_" . $pc_batch;

}
elsif ( $context eq "T")
{
my $trading_entity_id= $args{'trading_entity_id'} || die "ERROR: trading_entity_id is mandatory in the context of Trading Entity\n";
$po_id= $args{'po_id'} || die "ERROR: po_id is mandatory in the context of Trading Entity\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $trading_entity_id . "_" . $batch_id . ".par";
$param_archive_loc=$ENV{'NAS'} . "/infodel/archive/monthly/" . $workflow . "_" . $trading_entity_id . "_" . $batch_id . ".par";
$runinstance = $trading_entity_id . "_" . $batch_id;

}
elsif ( $context eq "F")
{
$po_id= $args{'po_id'} || die "ERROR: po_id is mandatory in the context of Firm\n";
my $firm_id= $args{'firm_id'} || die "ERROR: firm_id is mandatory in the context of Firm\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $firm_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$param_archive_loc=$ENV{'NAS'} . "/infodel/archive/monthly/" . $workflow . "_" . $firm_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$runinstance = $firm_id . "_" . $batch_id . "_" . $pc_batch;

}
else
{
die "ERROR:Context flag values should be one among I,P,T or F where as the passed values is $context \n";
}


#------------------------------------------------------------------------------
# SATHISH - 2010.11.30
# Service priority queried from edb - Function uses RunOracleSP.pl
#
# SAMPLE OUTPUT:
#    [:v_serviceName=GWMPP04_H]
#    [:c_priority=H]
#
# Process the output to get the priority and append to the connection string in ARGV
# DEFAULT PRIORITY = L  (low)
#
print "$po_id\n";
print "$folder\n";
print "$context\n";
print "INFO: Getting resource priority for [$po_id, $folder, $context]\n";
my $priority='L';
my $env=$ENV{'env'};
my $priorityoutput=`/nas/apps/util/Perl12c/bin/perl /apps/infa/${env}inf/server/infa_shared/ExtProc/RunOracleSP.pl --env=${env} --DB=EDB --SP="GET_RESOURCE_MGMT_DETAILS(100,$po_id,'ETL Processing','$folder',:v_serviceName,:c_priority,0,'$context')"`;
if ($? > 0) {
        print "WARNING: Failed to get service priority from EDB [$po_id][ETL Processing][$folder][$context].  Assuming LOW priority.\n";
} else {
	($priority)=($priorityoutput =~ m/\[:c_priority=(.*?)\]$/gm);
}
print "INFO: PRIORITY:$priority\n";


foreach my $key (keys %args) {
	if ($key =~ m/dbconnection/i) {
		my $keyval=$args{$key};
		# print "DEBUG:   OLD:${keyval}\n";
		my ($firstpart,$secondpart) = ($keyval =~ m/(.*)_(L|H|M)$/g);
		if ($secondpart) {
			# print "DEBUG:   NEW:${firstpart}_${priority}\n";
			$args{$key}="${firstpart}_${priority}";
		} else {
			$args{$key}="${keyval}_${priority}";
		}
	}
}

foreach my $key (keys %args) {
	print "$key=$args{$key}\n";
}
#------------------------------------------------------------------------------


if ( $businessdayonly eq "Y" )
{
   $po_id= $args{'po_id'} || die "ERROR: po_id is mandatory while passing businessdayonly=Y paramter to the script \n";
   #$runflag = `/apps/sei/gwm/batch/$ENV{'env'}/controlm/scripts/isBusinessDay.pl --env=$ENV{'env'} --po=$po_id --debug=0`;
   $runflag = `/nas/apps/util/Perl/bin/perl -I/nas/gwmt3/batch/$ENV{'env'}/controlm/script /apps/sei/gwm/batch/$ENV{'env'}/controlm/scripts/isBusinessDay.pl --env=$ENV{'env'} --po=$po_id --debug=0`;
   my $rc1; $rc1 = $? >> 8; 
   if ($rc1 > 0){
   print  "Error : Error calling isBusinessDay.pl \n";
   print $runflag;
   exit $rc1;
   }
  
}
else
{
$runflag = "Y";
}

if ( $runflag eq "Y" )
{

$errorlog = $ENV{'HOME'}. "/" . $errorlog . "_". "$runinstance" . ".err";

store(\%args,$ENV{'HOME'} . "/startetlargs.$$") || die "Error: Cannot store the startetlworkflow arguments to HOME_Dir/startetlargs.$$ \n";
my $extprocdir=$ENV{'PMRootDir'} . "/ExtProc";

system("$extprocdir/sbparamfilecreation.sh parentpid=$$") == 0 || die "Error : Cannot call or error in the sbparameterfilecreation.sh script \n";

my $reject_file_name;

if ( $checkrejectfile eq "Y" )
{
 
$reject_file_name=`sed -n 's/\$\$RejectFileName=//p' $paramfile` || die "ERROR: RejectFileName parameter is mandatory parameter file to check reject files \n";

}


# ------------------------------------------------------------------------------
# Run the pmcmd command and retain the output in a variable. Note that the
# setenv script must be run in order to ensure the pmcmd command has the
# correct environment variables set. 
#
my $pmcmd;my $rc;
if ( $startfrom eq "N" )
{
$pmcmd=`pmcmd startworkflow -sv $ENV{'INT_SVC'} -d $ENV{'DOMAIN_NAME'} -u wf_runner -p wfrunner -f "$folder" -paramfile "$paramfile" -nowait -rin "$runinstance" "$workflow"`;
$rc = $? >> 8; 
##move($paramfile,$param_archive_loc) || die "Error moving the generated parameter file to archive location $param_archive_loc \n";
}
else
{
$pmcmd=`pmcmd startworkflow -sv $ENV{'INT_SVC'} -d $ENV{'DOMAIN_NAME'} -u wf_runner -p wfrunner -f "$folder" -startfrom "$startfrom" -paramfile "$paramfile" -nowait -rin "$runinstance" "$workflow"`;
$rc = $? >> 8; 
##move($paramfile,$param_archive_loc) || die "Error moving the generated parameter file to archive location $param_archive_loc \n";

}


if ($rc > 0 and $rc != 3) {
    print "ERROR: Unknown workflow error occured. pmcmd command output follows:\n\n";
    print $pmcmd;
    # Exit with whatever code pmcmd returned 
    exit $rc; 
} 


if ($pmcmd =~ m/ERROR: Workflow.*is disabled/g) 
{
 #print $pmcmd;
 print "Workflow is in disabled state \n\n";
} 
else
{

if ($rc == 3)
{

#-------------------------------------------------------------------------------    
# Parse workflow log name out of the command output and display it. 
# Workflow log file: [/apps/infa/d02inf/server/infa_shared/WorkflowLogs/wf_LOAD_CA_NOTIFICATION.log]
#

my $wflog;
my $rc2;
my $sesslog;
my $errorsesslog;
my $line_from;
my $line_to;
my $lines;
$lines="";
my $convertlog;
my $error_count = 1;
$wflog=`infacmd.sh GetWorkflowLog -dn $ENV{'DOMAIN_NAME'} -fm Text -is $ENV{'INT_SVC'} -rs $ENV{'REP_SVC'} -ru wf_runner -rp wfrunner -fn "$folder" -wf $workflow -in $runinstance`;
$rc2 = $? >> 8;
if ($rc2 > 0 ) {
    print "ERROR: Workflow has failed, but couldn't get the workflow or session log.\nPlease get the logs from workflow monitor or contact ETL admins.\nGetWorkflowLog error message: \n\n";
    print $wflog;
    # Exit with whatever code pmcmd returned 
    exit $rc2; 
} 
    #-------------------------------------------------------------------------------
    # Parse list of session logs out of workflow log and display each one. 
    # [Writing session output to log file [/apps/infa/c03inf/server/infa_shared/SessLogs/s_m_QTZ_DSS_ETLRUN_UPDATE_POST.log].].
    #
    open(LOG, ">>$errorlog") || die("Error: cannot open/append file $errorlog \n");
    print LOG "Workflow Name       : $workflow \nWorkflow Status     : Failed \nRun Instance        : $runinstance \n";
    pos($wflog) = 0;
    while ($wflog =~ m/Writing session output to log file \[([\w\/\.]*?)\]/g) 
    {
      $sesslog= $1; 
      $errorsesslog = "$ENV{'HOME'}" . "/sesslog.$$";
      $convertlog = `infacmd.sh ConvertLogFile -in $sesslog".bin" -fm Text -lo $errorsesslog`;
      if (  `grep ': ERROR :' $errorsesslog | wc -l` > 0 )
        { 
            $sesslog =~ m/SessLogs\/(.*)\.log/;
            print LOG "Failure             : $error_count \nSession Name        : $1 \nError Message       :\n";
            $line_from =`sed -n '/: ERROR :/=' $errorsesslog | head -1`;
            $line_to = `wc -l $errorsesslog | awk '{print $1}'`;
            $line_to = chomp($line_to) - 1;
            $lines = `perl -ne 'print if $line_from .. $line_to' $errorsesslog`;
            print LOG $lines;
            $error_count++;

        }
       unlink ($errorsesslog) || die("Error: Cannot delete the converted session log file $errorsesslog \n");

    }
    
    while ($wflog =~ m/Command task instance (.*) did not complete successfully/g)
    {
            print LOG "Command Task Failure :Command task $1 did not complete successfully \n";
            $error_count++;
            print LOG "Pmcmd Command sysout :\n $pmcmd \n"; 
    }

    if ($error_count > 0 )
    {
    print "Workflow: $workflow failed for the following reason \n";
    $lines = `cat $errorlog`;
    }
    else
    {
    print "Workflow has failed but couldnt get the error from workflow log or session log\n";
    }
    print "\n<-------------------------------------Workflow/Session error message---------------------------------->\n";
    print "$lines \n";
    close (LOG);
}
else
{
 print "$workflow workflow ran successfully \n" ; 

if ( $checkrejectfile eq "Y" )
{
   chomp($reject_file_name);
   if ( -e $reject_file_name )
   {
     print "FILE HAS BEEN REJECTED \n";
     exit 4;
   }
}

}

}
if ( -e $errorlog) { unlink ($errorlog) || die("Error: Cannot delete the workflow error log file $errorlog \n") }; 


exit $rc;

}
else
{
print "Not running the workflow since it is not a business day \n";
}

