#! /bin/sh
###################################################################################
#  1. Script us used to create a list file based on the list of file in a specfic 
#     Directory.           
###################################################################################
if [ $# -lt 5 ] || [ $# -gt 6 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi

cd $1
#sed -i -- 's/"*_Ltd_MiFIR_*$5*"/' SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
#sed 's/"*_Ltd_MiFIR_*$5*"//' SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt > tmpfile; mv tmpfile SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
#new="$(sed 's/*_Ltd_MiFIR_*$5*//' SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt)"; echo "$new" > SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
#sed '/^[A-Z]/d' SEI_Investments_Ltd_MiFIR_C_"$2"_"$3"_"$5.txt;
#abcd='_Ltd_MiFIR_334f4.XML'
#sed -i "/${abcd}/d" / SEI_Investments_Ltd_MiFIR_C_$2_$3_$5.txt; 
#sed -i 's/_Ltd_MiFIR_334f4.XML\(.*baz\)/bar\1/';
sed -i '/^*/d' SEI_Investments_Ltd_MiFIR_C_$2_$3_$5.txt;
#sed -i -e 's/*_Ltd_MiFIR_*334f4*.XML/./g' SEI_Investments_Ltd_MiFIR_C_$2_$3_$5.txt;