#!/bin/bash 
if [ `grep -c "|" $1/$2` -eq 0 ]; then 
sed -e 's/,/|/g' $1/$2 | perl -pe 's{("[^"]+")}{($x=$1)=~tr/|/,/;$x}ge' | sed -e 's/"//g' > $1/TGT_$2 ; 
`sh $3/archiveetlfiles.sh $1 $2`; 
mv $1/TGT_$2 $1/$2;
fi
