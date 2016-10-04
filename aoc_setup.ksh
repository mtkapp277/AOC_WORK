#!/bin/ksh
# This script is to setup and kick off the awk scripts to format the log files

while getopts :h:D:d:t:c:e:w: ARGUMENTS ; do
# getopts needs each flag to have an argument in order to work
	case ${ARGUMENTS} in 
		h) 	echo "-help"
			echo "-D - DEFAULTS"
			echo "-d - Date [YYYY-MM-DD]"
			echo "-t - Time [hhmm-hhmm]"
			echo "-c - Test Case [1-8]"
			echo "-e - Full Path to EST sita log"
			echo "-w - Full Path to WST sita log"
			exit 
			;;	
		D)	echo "Using DEFAULT logs ${OPTARG}"
			EST_LOG=${HOME}/GIT/AOC_WORK/csp_client_est_sita_ORIG
			WST_LOG=${HOME}/GIT/AOC_WORK/csp_client_wst_sita_ORIG
			DATE=$( date +"%Y-%m-%d" ) 
			TIME="0000-$( date +"%H%M" )"
			CASE=${HOME}/GIT/AOC_WORK/PDC_MATRIX.compare
			;;	
		d) 	echo "Date:${OPTARG} [YYYY-MM-DD]"
			DATE=${OPTARG}
			;;	
		t)	echo "Time:${OPTARG} [hhmm-hhmm]"
			TIME=${OPTARG} 
			;;	
		c) echo "Test Case:${OPTARG}";;	
		e)	echo "EST:${OPTARG}"
			EST_LOG=${OPTARG}
			;;	
		w)	echo "WST:${OPTARG}"
			WST_LOG=${OPTARG}
			;;	
	esac
done
if [[ ${EST_LOG} = "" ]]; then
	EST_LOG=${HOME}/GIT/AOC_WORK/csp_client_est_sita_ORIG
fi
if [[ ${WST_LOG} = "" ]]; then
WST_LOG=${HOME}/GIT/AOC_WORK/csp_client_wst_sita_ORIG
fi
if [[ ${CASE} = "" ]]; then
	CASE=${HOME}/GIT/AOC_WORK/PDC_MATRIX.compare
fi

echo "------------------ CURRENT SETTINGS ----------------------"
echo "DATE=${DATE}"
echo "TIME=${TIME}"
echo "EST_LOG=${EST_LOG}"
echo "WST_LOG=${WST_LOG}"
echo "CASE=${CASE}"
echo "----------------------------------------------------------"

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

for SITA_LOG in ${EST_LOG} ${WST_LOG}; do
	echo "\nWorking ${SITA_LOG}"
	SITA_LOG_NAME=$( echo ${SITA_LOG} | cut -d "/" -f 8 | cut -d "_" -f 1-4 )
	echo "SITA_LOG_NAME=${SITA_LOG_NAME}"

	FIRST_DATE=$( head -1 ${SITA_LOG} | awk '{print $1}' )
	echo "FIRST_DATE=${FIRST_DATE}"

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
	${HOME}/GIT/AOC_WORK/parseLogfile.awk -v LOG_DIRECTION="${ZONAL}" -v FIRST_DATE="${FIRST_DATE}" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out
	echo "=========================================================================================================================="
done

echo "\nTime sorting SITA_LOGS_COMBINED.out" ##        V this grep removes blank lines
cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out | sort | grep -v -e "^$" > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out

INPUT_DATE=$( echo ${DATE} | awk '{split($0,date_array,"-"); print date_array[1] date_array[2] date_array[3] }' )

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

TOSS=${SITA_TEST_REPO}/OUT_OF_TIME_RANGE.out
KEEP=${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED.out
touch ${TOSS}
touch ${KEEP}

echo "Filtering out by Date"
cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out | grep "${DATE}" | \
	#awk -v START_SS=${START_SS} -v FINISH_SS=${FINISH_SS} -v KEEP=${KEEP} -v TOSS=${TOSS} '{ if ( $3 >= START_SS && $3 <= FINISH_SS ){print $0 >> KEEP } else {print $0 >> TOSS } }' 
	awk -v START_SS=${START_SS} -v FINISH_SS=${FINISH_SS} -v KEEP=${KEEP} -v TOSS=${TOSS} '{ if ( $3 >= START_SS && $3 <= FINISH_SS ){print $0 } }' 
${HOME}/GIT/AOC_WORK/fixHeader.awk ${KEEP} > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out

echo "Starting Comparision work... i think"

ANALYZE_FILE=${SITA_TEST_REPO}/TEST_CASE_FILTER.out
IGNORED_FILE=${SITA_TEST_REPO}/TEST_CASE_IGNORED.out
touch ${ANALYZE_FILE}
touch ${IGNORED_FILE}

echo "\nGetting TEST CASE LINE"
for TEST_CASE in $( cat ${CASE} | sed -e "s@ @_@g" | grep "<BEGIN" ); do

	FLID=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $2}' )
	ITER=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $3}' )
	TYPE=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $4}' )
	echo "${FLID} | ${ITER} | ${TYPE}"
	${HOME}/GIT/AOC_WORK/correspondence.awk -v FLID="${FLID}" -v ITER="${ITER}" -v TYPE="${TYPE}" -v ANALYZE_FILE="${ANALYZE_FILE}" -v IGNORED_FILE="${IGNORED_FILE}" ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out

#	GREP_LINE=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $2, $3, $4}' )
#	echo "grepping \"${GREP_LINE}\""
#	grep "${GREP_LINE}" ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out >> ${SITA_TEST_REPO}/TEST_CASE_FILTER.out
done

