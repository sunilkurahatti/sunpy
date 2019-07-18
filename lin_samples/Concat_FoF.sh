#! /bin/sh
#echo $1
if [ -s $PMTargetFileDir/fund_of_fund_hdr.csv ] && [ -s $PMTargetFileDir/fund_of_fund_dtl.csv ]
then
cat $PMTargetFileDir/fund_of_fund_hdr.csv $PMTargetFileDir/fund_of_fund_dtl.csv > $PMTargetFileDir/$1
rm $PMTargetFileDir/fund_of_fund_hdr.csv
rm $PMTargetFileDir/fund_of_fund_dtl.csv

else
        if [ -s $PMTargetFileDir/$1 ]
            then
                rm $PMTargetFileDir/$1
        fi
fi

RETCODE=$?
if [ $RETCODE -ne 0 ]
  then
    echo "ERROR:Concat FoF Header and Detail Script Failed"
    exit 1
fi
