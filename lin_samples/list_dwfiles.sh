#! /bin/sh
###################################################################################
#  1. Script us used to create a list file based on the list of file in a specfic 
#     Directory.           
###################################################################################

cd $1
rm -f flat_xml_file1*
rm -f *MiFIR_HDR_*
rm -f "*MiFIR_FIRM*.XML.bkp"
rm -f "*MiFIR_DL*"
rm -f "*MiFIR_FIRM*.XML"
rm -f "*MiFIR_DL*.XML.tmp"
if [ $# -lt 5 ] || [ $# -gt 6 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

cd $1
touch  "$i""SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
rm  "$i""SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
for i in *_Ltd_MiFIR_*$5*.XML; 
do   
echo "$i" >> "SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
done;
