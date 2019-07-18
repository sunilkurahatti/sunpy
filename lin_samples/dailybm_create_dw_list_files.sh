cd $1
rm benchmark_dw_files_list.lst;

for i in *GWMP_IP_DAY_1.txt;
do
echo "$i" >> benchmark_dw_files_list.lst;
done
