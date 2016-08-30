#!/bin/ksh

while getopts :D:d:t:c:e:w: ARGUMENTS
	case ${ARGUMENTS} in 
		D) echo "Using DEFAULT logs ${OPTARG}";;	
		d) echo "Date:${OPTARG}";;	
		t) echo "Time:${OPTARG}";;	
		c) echo "Test Case:${OPTARG}";;	
		e) echo "EST:${OPTARG}";;	
		w) echo "WST:${OPTARG}";;	
	esac
done

#cat csp_client_wst_sita_ORIG | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@	@<TAB>@g" | sed -e "s@.\$@<CR>@g" | sed -e "s@\n@<LF>@g" > no_spec_char_wst.log

#echo "Fixing wst"
#cat csp_client_wst_sita_ORIG | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@	@<TAB>@g" > no_spec_char_wst.log
#echo "Fixing est"
#cat csp_client_est_sita_ORIG | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@@@g" | sed -e "s@	@<TAB>@g" > no_spec_char_est.log


for SITA_LOG in ~kappm/GIT/AOC_WORK/csp_client_wst_sita_ORIG ~kappm/GIT/AOC_WORK/csp_client_est_sita_ORIG; do
	cd ~kappm/
	mkdir -m 777 SITA_TEST_REPO
	echo "\nCreated \"SITA_TEST_REPO\""
	SITA_TEST_REPO=${USER}/SITA_TEST_REPO
	SITA_LOG_NAME=$( echo ${SITA_LOG} | cut -d "_" -f 1-4 )
	echo "Cleaning up sita log files now and replacing control characters, tabs, & new lines"
	cat ${SITA_LOG} | 	sed -e "s@@@g" | \
						sed -e "s@@@g" | \						
						sed -e "s@@@g" | \						
						sed -e "s@@@g" | \						
						sed -e "s@	@<TAB>@g"  > ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED
	echo "\nCreated ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED"
	
	echo "\n\nParsing cleaned up log file & adding in header now..."
	ZONAL=$( echo ${SITA_LOG} | cut -d "_" -f 3 )
	echo "\nparseLogfile.awk -v LOG_DIRECTION=\"${ZONAL}\" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> SITA_LOGS_COMBINED.out"
	parseLogfile.awk -v LOG_DIRECTION="${ZONAL}" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out
done

echo "\nTime sorting SITA_LOGS_COMBINED.out"
cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out | sort  > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out

echo "Parsing lines & updating header information..."
parseLine.awk ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out > parsedAOC.out
