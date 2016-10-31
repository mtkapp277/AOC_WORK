#!/bin/awk -f 

# This awk is designed to to through the aoc_combined.out file and grab variables from each line and finish setting up the header.

BEGIN {
	DATE=""
	TIME=""
	BASE=""
	ZERO=""
	LDIR=""
	ITER=""
	FLID=""
}

{
	MSG=""
	split($0,line_array," ")
	DATE=line_array[1]	
	TIME=line_array[2]	
	SECS=line_array[3]	
	BASE=line_array[4]
	FLID="<UNK_FLID>"
	ITER="<ITER>"
	TYPE="<UNK_TYPE>" 
	LDIR=line_array[8]	

	#ZERO=line_array[3]	
	#ITER=line_array[5]
	MSG=$9
	for ( i = 10; i<= NF; i++ ){
		if ( line_array[i] == "Type" && TYPE == "<UNK_TYPE>" ){
			TYPE=line_array[i-1]
		}
		else if ( line_array[i] == "Received" && line_array[i+2] == "message"  && TYPE == "<UNK_TYPE>" ){
			TYPE=line_array[i+1]
		}
		if ( line_array[i] == "Flight_ID:" && FLID == "<UNK_FLID>" ){
			FLID=line_array[i+1]
		}
		else if ( line_array[i] == "CLEARANCE" && line_array[i+1] == "<NEWLINE>" && FLID == "<UNK_FLID>" ){
			FLID=line_array[i+2]
		}
		MSG=MSG " " $i
	}
	#ITER=ARR[FLID]++
	ARR[FLID]++    # THIS IS HOW WE COUNT THE NUMBER OF TIMES A FLID IS SEEN
	ITER=ARR[FLID]
	print DATE " " TIME " " SECS " " BASE " " FLID " " ITER " " TYPE " " LDIR " " MSG
}

END {
}
