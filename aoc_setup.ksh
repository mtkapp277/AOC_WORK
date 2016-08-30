#!/bin/ksh

while getopts :h:D:d:t:c:e:w: ARGUMENTS ; do
	case ${ARGUMENTS} in 
		h) 	echo "-help"
			echo "-D - DEFAULTS"
			echo "-d - Date"
			echo "-t - Time"
			echo "-c - Test Case"
			echo "-e - Full Path to EST sita log"
			echo "-w - Full Path to WST sita log"
			;;	
		D) echo "Using DEFAULT logs ${OPTARG}";;	
		d) 	echo "Date:${OPTARG} [YYYY-MM-DD]"
			DATE=${OPTARG}
			;;	
		t)	echo "Time:${OPTARG} [hhmm-hhmm]"
			TIME=${OPTARG} 
			;;	
		c) echo "Test Case:${OPTARG}";;	
		e) echo "EST:${OPTARG}";;	
		w) echo "WST:${OPTARG}";;	
	esac
done

#sed -e "s@.\$@<CR>@g" | sed -e "s@\n@<LF>@g" > no_spec_char_wst.log

cd ${HOME}
if [[ -d ${HOME}/SITA_TEST_REPO ]]; then
	echo "Directory already exists "
	rm -rf ${HOME}/SITA_TEST_REPO
	echo "\nStarting Fresh..."
	mkdir -m 777 SITA_TEST_REPO
	echo "\nCreated \"SITA_TEST_REPO\""
else
	mkdir -m 777 SITA_TEST_REPO
	echo "\nCreated \"SITA_TEST_REPO\""
fi
SITA_TEST_REPO=${HOME}/SITA_TEST_REPO
echo "SITA_TEST_REPO=${SITA_TEST_REPO}" 

for SITA_LOG in ~kappm/GIT/AOC_WORK/csp_client_wst_sita_ORIG ~kappm/GIT/AOC_WORK/csp_client_est_sita_ORIG; do
	echo "\nWorking ${SITA_LOG}"
	SITA_LOG_NAME=$( echo ${SITA_LOG} | cut -d "/" -f 8 | cut -d "_" -f 1-4 )
	echo "SITA_LOG_NAME=${SITA_LOG_NAME}"

	echo "Cleaning up sita log files now and replacing control characters, tabs, & new lines"
	cat ${SITA_LOG} | 	sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@	@<TAB>@g"  > ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED
	echo "\nCreated ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED"
	
	echo "\n\nParsing cleaned up log file & adding in header now..."
	ZONAL=$( echo ${SITA_LOG_NAME} | cut -d "_" -f 3 )
	echo "\nparseLogfile.awk -v LOG_DIRECTION=\"${ZONAL}\" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> SITA_LOGS_COMBINED.out"
	${HOME}/GIT/AOC_WORK/parseLogfile.awk -v LOG_DIRECTION="${ZONAL}" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out
	echo "=========================================================================================================================="
done

echo "\nTime sorting SITA_LOGS_COMBINED.out"
cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out | sort  > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out

START_TIME=$( echo ${TIME} | cut -d "-" -f 1 )
START_HH=$( echo ${START_TIME} | cut -c 1-2 )
START_MM=$( echo ${START_TIME} | cut -c 3-4 )
START_SS=$(( ${START_HH}*3600 + ${START_MM}*60 - 60 )) # Subtacting a FLUX minute to capture initial Events (missing seconds)
#echo "${START_TIME} | ${START_HH} | ${START_MM} | ${START_SS} "

FINISH_TIME=$( echo ${TIME} | cut -d "-" -f 2 )
FINSIH_HH=$( echo ${FINISH_TIME} | cut -c 1-2 )
FINSIH_MM=$( echo ${FINISH_TIME} | cut -c 3-4 )
FINISH_SS=$(( ${FINSIH_HH}*3600 + ${FINSIH_MM}*60 + 60 )) #Adding a FLUX minute to capture last events (missing seconds)
#echo "${FINISH_TIME} | ${FINSIH_HH} | ${FINSIH_MM} | ${FINISH_SS} "

echo "Start Secs:${START_SS}"
echo "Finish Secs:${FINISH_SS}"

if [[ ${DATE} != "" ]]; then
	echo "Filtering out by Date"
	cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out | grep "${DATE}" | awk -v START_SS=${START_SS} -v FINISH_SS=${FINISH_SS} '{ if ( $3 >= START_SS && $3 <= FINISH_SS ){ print $0} }' > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED.out
	${HOME}/GIT/AOC_WORK/fixHeader.awk ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED.out > ${SITA_TEST_REPO}/parsedAOC_FILTERED.out
else
	echo "Parsing lines & updating header information... [NOT FILTERED]"
	${HOME}/GIT/AOC_WORK/fixHeader.awk ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out > ${SITA_TEST_REPO}/parsedAOC.out
fi

