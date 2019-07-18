#!/usr/bin/perl -w
use strict;
use Storable;

#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>
#
#   Name		: paramfilecreation.sh
#   Description	: Creates a parameter file based on the template file and substitutes variables. 
#   Usage		: paramfilecreation.sh var1=value1 var2=value2 ......
#   Note 		: 1. No spaces before or after = while passing parameters
#          		  2. No Spaces in template parameter file while mentioning the vairables with in { }
#   Revision		: 24-Dec-2008    LM      		Original version 
#
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>

#------------------------------------------------------------------------------
# Retrieve the arguments passed to the script and basic validation.
#

$ENV{LC_ALL}="C";
my %args;my %hash1;my %hash2;
foreach (@ARGV) 
  {
    m/(\w+)=([\S\w\s,\.]+)/;
    $args{lc($1)} = $2;
  }

if( exists $args{parentpid})
{
my $parentpid=$args{parentpid};
my $href=retrieve($ENV{'HOME'} . "/startetlargs.$parentpid");
%hash2=%$href;
unlink ($ENV{'HOME'} ."/startetlargs.$parentpid") || die("Error: Cannot delete the file HOME/startetlargs.$parentpid ");
}
else
{
%hash2 = %args;
}

my $context= $hash2{'context'} || die "ERROR: context is mandatory \n";
my $batch_id=uc($hash2{'batch'}) || die "ERROR: batch is mandatory \n";
my $folder=$hash2{'folder'} || die "ERROR: folder is mandatory \n";
my $workflow=$hash2{'workflow'} || die "ERROR: workflow is mandatory \n";
my $pc_batch= $hash2{'pc_batch'} || die "ERROR: pc_batch is mandatory \n";
my $stmt_reserve_id= $hash2{'stmt_reserve_id'};


if ( defined $ENV{'DOMAIN_NAME'} && defined $ENV{'NODE_NAME'} && defined $ENV{'INT_SVC'} && $ENV{'REP_SVC'} && $ENV{'PMRootDir'})
{
#print " \nTrying to start the Workflow:$workflow in Repository:$ENV{'REP_SVC'} using Integration Service : $ENV{'INT_SVC'} \n\n";
}
else
{
die "ERROR : .profile is not set properly for the user. Please run/set the .profile /n";
}

my $paramfile;my $runinstance;

if ( $context eq "I" )
{
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_i_" . $batch_id . ".par";
$runinstance = $batch_id;
}
elsif ( $context eq "P" )
{
my $po_id= $hash2{'po_id'} || die "ERROR: PO_ID value is mandatory in the context of PO\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $stmt_reserve_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$runinstance = $stmt_reserve_id . "_" . $batch_id . "_" . $pc_batch;
}
elsif ( $context eq "T")
{
my $trading_entity_id= $hash2{'trading_entity_id'} || die "ERROR: trading_entity_id is mandatory in the context of Trading Entity\n";
my $po_id= $hash2{'po_id'} || die "ERROR: po_id is mandatory in the context of Trading Entity\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $trading_entity_id . "_" . $batch_id . ".par";
$runinstance = $trading_entity_id . "_" . $batch_id;
}
elsif ( $context eq "F")
{
my $po_id= $hash2{'po_id'} || die "ERROR: po_id value is mandatory in the context of Firm\n";
my $firm_id= $hash2{'firm_id'} || die "ERROR: firm_id value is mandatory in the context of Firm\n";
$paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . "_" . $firm_id . "_" . $batch_id . "_" . $pc_batch . ".par";
$runinstance = $firm_id . "_" . $batch_id . "_" . $pc_batch;
}
else
{
die "ERROR:Context flag values should be I or P or F where as the passed values is $context \n";
}


#-----------------------------------------------------------------------------------
# Generating a parameter file based on the template file by replacing the variables.
#
  my $template_paramfile;$template_paramfile = $ENV{'PMRootDir'} . "/paramfiles/" . $workflow . ".par";
  if ( -e $template_paramfile )
  {
      open(FILE, "<$template_paramfile") or die("Unable to open $template_paramfile $!");
      my $t = $/;
      undef $/;
       
       my $config = <FILE>;close(FILE);
       $/ = $t;

       # Change any ctrl-m's to nothings.
       $config =~ s/\cM$/\n/g;
       my $var; my $val;
       $var=`cat $template_paramfile`;
   
       # ------------------------------------------------------------------------------
       #  Replace all environment variable with the equivalent value in the
       #

       pos($config) = 0;
       while ($config =~ m/\{(.*?)\}/g) 
       {
           $var = $1;
           if (exists $hash2{$var}) 
           {
               $val= $hash2{$var};
               chomp($val);
               $config =~ s/\{$var\}/$val/g;
               delete $hash2{$var};
           }
           else 
           {
               die "ERROR: Unable to locate value for $var used in template parameter file from the paramters passed to the script  \n";
           }
       }
       # ------------------------------------------------------------------------------------------------ 
       #  Validate the parameters passed to scripts exist in Parameter file and if dont exist error out. 
       #

       delete $hash2{'startfrom'};

       if (scalar(keys %hash2) >0 )
       {
          print "Error: The following parameters passed to script are not used in parameter file\n";
          while ( my ($k,$v) = each %hash2 )
          {
             print "$k=$v\n";
          }
          die "Pass the correct parameters to the script\n";
       }

       pos($config) = 0;
   
       # ------------------------------------------------------------------------------------------------ 
       #  Write the Modified file to Parameter file. 
       #
        $config=~ s/\$NAS/$ENV{'NAS'}/g; 
       if ( -e $paramfile )
       {
           unlink($paramfile) or die "Parameter file permission Issue.\n";
       }
       open OUT,"+>$paramfile" or die "ERROR: Unable to open $paramfile due to $!";
       
       print OUT $config;
       close OUT;
       print "\n<--------------------------------------Created parameter file----------------------------------------->\n";
       chmod(0777,$paramfile)or die "Parameter file permission Issue.\n";

       print "Parameter file name : $paramfile \n";
       print $config;
       print "\nParameter file creation completed successfully \n";
 }
 else
 {
    die "ERROR : Template Parameter file $workflow.par not found \n";
 }

#
# Completed generating the parameter file.
#-----------------------------------------------------------------------------------

