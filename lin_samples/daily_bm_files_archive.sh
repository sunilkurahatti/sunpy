#! /bin/sh
###################################################################################
#  1. Script is used to Archive files based on the file name.           
###################################################################################

cd $1
for i in *GWMP_IP_DAY_1.txt*;
do   
#echo "$i" > benchmark_dw_files_list.lst
"$2"/archiveetlfiles.sh "$i" "$1" monthly
done
