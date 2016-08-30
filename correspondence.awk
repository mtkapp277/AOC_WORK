#!/bin/awk -f

{
	if( $4 == FLID && $5 == ITER && $6 == TYPE ){
		print $0 >> ANALYZE_FILE
	}
	else {
		print $0 >> IGNORED_FILE
	}
}
