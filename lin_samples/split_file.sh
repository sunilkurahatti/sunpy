#! /usr/bin/perl
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>
#
#   Name:         split_file.sh
#   Description:  Input file contains data for different bank_ids.The Starting line is of the format *<bank_id>
#                 this scripts splits the file into multiple files with the name bank_id
#
#    
#
#<><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><><>>



#------------------------------------------------------------------------------
# 
#


use warnings;
use strict;
my $file_name=$ARGV[0]."/".$ARGV[1];
open FILE,$file_name or die "can't open $ARGV[1]: $!\n";;
my $lineno=1;
my $line;
my $filename;
my %data;
my $key;
my $oldfile;
my $split_name;
while (<FILE>)
{
$line=$_;
if(substr($line,0,1) eq "*")
{
$filename=substr($line,1,length($line)-2).".txt";
}
else
{
if(defined $data{$filename})
{
$data{$filename}=$data{$filename}.$line;

}
else
{$data{$filename}=$line;}
}
}
close FILE;
system("rm -f $file_name");
foreach $key (keys %data)
{
$split_name=$ARGV[0]."/".$key;
        open FH,">$split_name";
print FH $data{$key};
close FH;
}



