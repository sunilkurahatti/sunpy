#!/bin/sh
# 

if [ "`date '+%M'`" -le "15" ];then
 tminutes=`expr 60 - \`date '+%M'\``
 thrs=`expr \`date '+%H'\` - 1`
 tdate=`date '+%m%d'`
else
tminutes=`expr \`date '+%M'\` - 15`
thrs=`expr \`date '+%H'\` `
if [ $tminutes -lt 10 ];then tminutes=`echo 0${tminutes}`;fi
tdate=`date '+%m%d'`
fi
cd $NAS/currency/BACS
timestamp=`echo ${tdate}${thrs}${tminutes}`
touch -t $timestamp bacs_dummy
find * -prune ! -newer bacs_dummy ! -name bacs_dummy -name BACS.OUT.\* ! -size 0 -prune | sed 's;./;;g'
