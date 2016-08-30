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

function printLine() {
	split($0,line_array," ")
	MSG=line_array[1] " " line_array[2] " " line_array[3] " " LOG_DIRECTION " " ITERATION " " FLID " " TYPE
	for ( i = 4; i<= NF; i++ ){
		MSG=MSG " " $i
	}
}

BEGIN {
	MSG="";
	ITERATION="<ITERATION>";
	FLID="<FLID>"
	TYPE="<TYPE>"
	STATUS="STOPPED"
}
{
	LINE=$0;
#	print "   LINE=" LINE
	if( STATUS == "STOPPED" ){
		if( $0 ~ /bytes of/ ){
			split($0,line_array," ")
			printLine()
			STATUS="STARTED"
		}
		else {
			next
		}
	}
	else { #STATUS == STARTED
		if(	$0 ~ /bytes of/ ){
			print MSG "\n"
			printLine()
		}
		else {
			MSG=MSG " <NEWLINE> " $0 
		}
	}
}
END {
	print MSG
}

