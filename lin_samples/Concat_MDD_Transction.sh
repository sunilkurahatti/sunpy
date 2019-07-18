#! /bin/bash
i=0
for filename1 in $(ls $NAS/$1/$2/*_Transaction_[0-9]*$3*)
do
  echo $filename1
  i=`expr $i + 1`
  a=`ls $filename1 | awk -F'[__]' '{print $2}'`
  echo $a
  filename2=`ls $NAS/$1/$2/*$a*_TransactionDetail*$3*`
  echo $filename2
  cat $filename1 $filename2 >> $filename1
  rm -f $filename2 
done
echo $i

