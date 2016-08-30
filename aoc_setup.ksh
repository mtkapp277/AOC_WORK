#!/bin/ksh

while getopts :d:t:c:e:w: ARGUMENTS
	case ${ARGUMENTS} in 
		d) echo "date ${OPTARG}";;	
	esac
done

echo "Fixing wst"
#cat csp_client_wst_sita_ORIG | sed -e "s@
cat csp_client_wst_sita_ORIG | sed -e "s@
echo "Fixing est"
cat csp_client_est_sita_ORIG | sed -e "s@

echo "awking wst"
aoc5.awk -v LOG_DIRECTION="wst" no_spec_char_wst.log  > aoc_combined.out
echo "awking est"
aoc5.awk -v LOG_DIRECTION="est" no_spec_char_est.log >> aoc_combined.out

#echo "sorting"
#cat aoc_combined.out | sort  > aoc_combined_sorted.out

echo "parsing lines"
parseLine.awk aoc_combined.out > parsedAOC.out