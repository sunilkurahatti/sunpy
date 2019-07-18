########################################################################################
# Purpose : Script will be used to append file to every record
# Created By : Chekuri
# Created Date : 17-Jan-2014
##########################################################################################

if [ $# -ne 2 ]
then
        echo "Usage: appendfilenametorecord.sh <file Directory> <File Name Start With>"
        exit 1
fi

if [ ! -d $1 ]
then
        echo "Invalid directory specified"
        exit 1
fi

# To handle file name with small letters | BChekuri | 11-Mar-2014 | Start
touch $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp
ls $1/`echo $2 | tr '[A-Z]' '[a-z]'`*.csv
if [ $? -eq 0 ]
then
  ls $1/`echo $2 | tr '[A-Z]' '[a-z]'`*.csv >> $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp
else
  touch $1/`echo $2 | tr '[A-Z]' '[a-z]'`"_tmpnil_appfilenametrec.csv"
fi

# To handle file name with small letters | BChekuri | 11-Mar-2014 | End
ls $1/$2*.csv
if [ $? -eq 0 ]
then
  ls $1/$2*.csv >> $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp
else
  touch $1/$2"_tmpnil_appfilenametrec.csv"
fi


#FILE_COUNT=`cat $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp | wc -l`
#if [ "$FILE_COUNT" -eq "0" ]
#then
#        touch $1/$2"_tmpnil_appfilenametrec.csv"
#        rm -f $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp
#        exit 0
#fi

echo ""
echo "Just before for looop..."
echo ""

for filename in `cat $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp`
do
        FILE_NAME=`echo $filename | awk -F'/' '{count=NF} {print $count}'`
        dos2unix $filename $filename
        cat $filename | awk -F'|' '{
                                        c=NF
                                        if( $c != "'"$FILE_NAME"'" )
                                        {
                                                print $0"|""'"$FILE_NAME"'"
                                        }
                                        else
                                        {
                                                print $0
                                        }
                                  }' >$filename"_tmp_appfilenametrec"
        cat $filename"_tmp_appfilenametrec" > $filename
        rm -f $filename"_tmp_appfilenametrec"
done

echo ""
echo "Commend completed successfully..."
echo ""

rm -f $1/wf_QTZ_GLOBETAX_RECLAIM_FILE_INCOMING.tmp

exit 0