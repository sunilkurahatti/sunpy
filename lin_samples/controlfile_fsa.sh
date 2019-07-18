# Script works only if input file has fields separated by Pipe(|)
#! /bin/sh

if [ $# -lt 5 ] || [ $# -gt 6 ]
  then
   echo " Wrong Sytax .. Usage : $0 Batch_File_Name "
   exit 1
fi
  
cd $1

#FSA XML File Exists
if [ `find $1 -name "*.FSA" -type f -print | wc -l` -gt 0 ] ; 
then
for i in *.FSA ; do	
	filename_fsa=`ls -1 *.FSA | sed 's/\(.*\)\..*/\1/'`
	runno_fsa=`ls -1 *.FSA1 | sed 's/\(.*\)\..*/\1/'`
	echo $filename_fsa
	echo $runno_fsa
	mv $1/dws_fsa_outextract_fsa.xml $1/$filename_fsa.xml 
		RETCODE=$?
       	  	 if [ $RETCODE -ne 0 ]
	        	 then	
	        	  echo "ERROR:Unable to Remove FSA XML temp Files. "
	         	 exit 1
	         fi
	echo $filename_fsa.xml >> $1/$2$3$4'C'$5.txt
	rm -f *.FSA
	rm -f *.FSA1
	rm -f dws_fsa_outextract_fsa.xml
done

fi
cd $1

if [ `find $1 -name "*.DL" -type f -print | wc -l` -gt 0 ] ; 
then

#DEALER XML File Exists
for i in *.DL; do	
	filename_dl=`ls -1 *.DL | sed 's/\(.*\)\..*/\1/'`
	echo $filename_dl
	mv $1/dws_fsa_outextract_dl.xml $1/$filename_dl.xml 
		RETCODE=$?
       	  	 if [ $RETCODE -ne 0 ]
	        	 then	
	        	  echo "ERROR:Unable to Remove Dealer XML temp Files. "
	         	 exit 1
	         fi
	echo $filename_dl.xml >> $1/$2$3$4'C'$5.txt
	rm -f *.DL
	rm -f *.DL1
	rm -f dws_fsa_outextract_dl.xml
done

fi

cd $1

if [ `find $1 -name "*.FSA" -type f -print | wc -l` -gt 0 ] || [ `find $1 -name "*.DL" -type f -print | wc -l` -gt 0 ] ;
then
	echo "Successfully created Ctrl File"

else
	touch $1/$2$3$4'C'$5.txt

fi
	

rm -f dummy.out
rm -f dummy1.out


	