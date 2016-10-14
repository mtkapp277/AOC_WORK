#!/bin/awk -f

{
	split($0,line_array," ")
	DATE=line_array[1]
	TIME=line_array[2]
	SECS=line_array[3]
	FLID=line_array[4]
	ITER=line_array[5]
	TYPE=line_array[6]
	LDIR=line_array[7]
	MSG="\n" DATE " " TIME " " SECS " " FLID " " ITER " " TYPE " " LDIR 
	for( i=8; i<=NF; i++ ){
		if( line_array[i] == "<NEWLINE>" ){
			MSG=MSG "\n  "	
		}
		else if( line_array[i] == "<TAB>" ){
			MSG=MSG "\t" 
			TAB_FLAG="T"
		}
		else {
			if( TAB_FLAG == "T"){
				TAB_FLAG="F"
				MSG=MSG  $i 
			}
			else {
				MSG=MSG " " $i 
			}
		}
	}
	print MSG
}
