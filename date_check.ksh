#!/bin/ksh

DATE=$1

while read line ; do
	if [[ ${line} < $DATE ]];then
		print $line is LESS than $DATE
	fi	
	if [[ ${line} > $DATE ]];then
		print $line is GREATER than $DATE
	fi	
	if [[ ${line} = $DATE ]];then
		print $line is EQUAL to $DATE
	fi	

done < date.list
