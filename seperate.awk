#!/bin/awk -f

{
	split($0,line_array," ")
	DATE=line_array[1]
	TIME=line_array[2]
	ZERO=line_array[3]
	LDIR=line_array[4]
	ITER=line_array[5]
	FLID=line_array[6]
	TYPE=line_array[7]
	MSG="\n" DATE " " TIME " " FLID " " ITER " " TYPE " " LDIR 
	for( i=9; i<=NF; i++ ){
		if ( line_array[i] == "<NEWLINE>" ){
			MSG=MSG "\n  "	
		}
		else {
			MSG=MSG " " $i 
		}
	}
	print MSG
}
