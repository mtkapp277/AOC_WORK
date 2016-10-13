#!/bin/awk -f

# I need to ignore the dates before the USER input date to initialize D=0

#  -v - DATE   - 2016-10-29
#  -v - TIME   - 1637-1711

function std_error(msg){
    gsub("\\\\","\\\\\\\\",msg)
    gsub("\"","\\\"",msg)  # These gsubs get rid of escape characters
    system("echo \""msg"\" >&2")
}


#function convertDate(DAY){
#	split(DAY,date_array,"-")
#	yyyymmdd=date_array[1] date_array[2] date_array[3]
#}

function getSeconds(DAY,CLOCK){
   
   if( DAY != current_day ){   # This if statement assumes the dates in the file are sorted correctly
       current_day = DAY;      # This can only see a date difference and add 1 (if date is a 7 day diff, then it still only adds 1)
       D=D+1;
   }
   
   split(CLOCK,time_array,":")
   HH=time_array[1]
   MM=time_array[2]
   SS=time_array[3]
   TOT_SEC = (D*24*3600) + (HH*60*60) + (MM*60) + (SS);
   #TOT_SEC = (HH*60*60) + (MM*60) + (SS);
   return TOT_SEC;
}

BEGIN {
	USER_DATE=DATE
	current_day=DATE;
	D=0
}

{
	LINE_DATE=$1
	LINE_TIME=$2

	MSG=""
	split($0,line_array," ")


	if( LINE_DATE < USER_DATE ){
		std_error("\nERROR: Date Out of Range - "$0)
	}
	else if( LINE_DATE >= USER_DATE ){
		TOT_SEC=getSeconds(LINE_DATE,LINE_TIME)
		for (i=1; i<=NF; i++ ){
			if( i == 3 ){
				MSG=MSG " " TOT_SEC
			}
			else {
				MSG=MSG " " $i
			}
		}
		print MSG
	}
}

