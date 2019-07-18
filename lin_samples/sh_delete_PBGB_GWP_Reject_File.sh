#1. Environment parameter: lower case (dv, it, i2, qa, q2 ,p2, i01, mo......) 
#	2. Folder and workflow names should be in the same case as in Informatica
#	3. Run mode parameters: lower case 
###################################################################################

#!/bin/sh 
#echo 'execution started'
if [ -f $1/$2 ]&&[ ! -s $1/$2 ]
then 
		rm $1/$2
fi 
#echo 'execution completed' 
