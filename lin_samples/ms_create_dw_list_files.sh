cd $1 $2 $3
touch  "$i"morningstar_dw_files_list.lst;
rm  "$i"morningstar_dw_files_list.lst;
touch  "$j"morningstar_hp_files_list.lst;
rm  "$j"morningstar_hp_files_list.lst;
if [ $2 == M ]; then
for i in DataWarehouse37*$2*;
do
echo "$i" >> morningstar_dw_files_list.lst;
done
for j in HistoricalPerformance23_*$2*;
do
echo "$j" >> morningstar_hp_files_list.lst;
done
elif [ $2 == D ] ; then
for i in DataWarehouse37*$2*;
do
odate=$(echo "$i" | sed "s/.*_\([^_]*[^.]*\).*\.[^.]*$/\1/");
echo "$i";
echo "$odate"
echo "$3";
if [ "$3" == "$odate" ] 
then
echo "$i" >> morningstar_dw_files_list.lst;
fi
done
for j in HistoricalPerformance23_*$2*;
do
odate=$(echo "$j" | sed "s/.*_\([^_]*[^.]*\).*\.[^.]*$/\1/");
echo "$j";
echo "$odate"
echo "$3";
if [ "$3" == "$odate" ] 
then
echo "$j" >> morningstar_hp_files_list.lst;
fi
done
else
exit
fi
