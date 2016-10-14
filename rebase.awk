#!/bin/awk -f

# The purpose of this script is to add a new field after the seconds (3) that rebases the start time to zero
	
{
	if( NR == "1" ){ # First line of file
		BASE_SECS=$3
	}
	
}

