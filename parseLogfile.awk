#!/bin/awk -f 

#cat csp_client_est_sita_ORIG | sed -e "s@^M@@g" | sed -e "s@^A@@g" | sed -e "s@^B@@g" | sed -e "s@^C@@g" > no_spec_char_est.log

#Types:
# CCP Type
# GRM Type
# PDC Type

#grep "Received [A-Z][A-Z][A-Z] message" csp_client_est_sita_ORIG | awk '{print $6}' | sort -u
#ACK
#CCI
#CCP
#CCR
#GRM
#PDC
#TIS

# HEADER ORDER:
# DATE TIME FLID ITER TYPE ZONAL   # Removing "ZEROS"
function printLine() {
	split($0,line_array," ")
#	MSG=line_array[1] " " line_array[2] " " line_array[3] " " LOG_DIRECTION " " ITERATION " " FLID " " TYPE
	MSG=line_array[1] " " line_array[2] " " TOT_SEC " " FLID " " ITERATION " " TYPE " " LOG_DIRECTION
	for ( i = 4; i<= NF; i++ ){
		MSG=MSG " " $i
	}
}
function getSeconds(CLOCK){
	split(CLOCK,time_array,":")
	HH=time_array[1]
	MM=time_array[2]
	SS=time_array[3]
	TOT_SEC = (HH*60*60) + (MM*60) + (SS);
	return TOT_SEC;
}

BEGIN {
	MSG="";
	TOT_SEC="<TOT_SEC>";
	FLID="<FLID>";
	ITERATION="<ITERATION>";
	TYPE="<TYPE>";
	STATUS="STOPPED";
}
{
	LINE=$0;
#	print "   LINE=" LINE
	if( STATUS == "STOPPED" ){
		if( $0 ~ /bytes of/ ){
			split($0,line_array," ")
			getSeconds(line_array[2])
			printLine()
			STATUS="STARTED"
		}
		else {
			next
		}
	}
	else { #STATUS == STARTED
		if(	$0 ~ /bytes of/ ){
			# This is basically saying once you come back around to another "bytes of" msg, Print out what you currently have in MSG
			#  then Start fresh (ie printLine)
			print MSG "\n" # This is the actually PRINT line. ABSOLUTELY NEEDED
			getSeconds($2)
			printLine()
		}
		else {
			MSG=MSG " <NEWLINE> " $0 
		}
	}
}
END {
	print MSG # THIS COULD BE CAUSING A DUPLICATE LINE
}

