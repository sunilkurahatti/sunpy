#! /bin/sh

cd /nas/gwmt3/batch/c45/currency
#$var1=find ACH_CD_*>SEK.TXT>sort -n -t = -k 1
find ACH_CD_*>SEK.TXT
sort -rn -t = -k 1 SEK.TXT
head -1 SEK.TXT

var="ACH_CD_3_DDMMYY"

echo ${var:7:1}

var1="ACH_CD_FRMH_1_DDMMYYYY"

sed -i -e 's/CD_F*_/CD_/g' SEK.TXT

