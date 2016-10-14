#!/bin/ksh
# This script is to setup and kick off the awk scripts to format the log files

function helper {
	echo "\nThis script will create a new directory (${HOME}/SITA_TEST_REPO) and combine and analyze the sita logs\n"
	echo "\t-h <any text> #Text is needed after -h because script uses getopts"
	echo "\t-D - DEFAULTS \n\t\tDATE=${DATE} \n\t\tTIME=${TIME} \n\t\tCASE=${CASE}"
	echo "\t-d - Date [YYYY-MM-DD]"
	echo "\t-t - Time [hhmm-hhmm]"
	echo "\t-c - Test Case [1-8]"
	echo "\t-e - Full Path to EST sita log"
	echo "\t-w - Full Path to WST sita log"
	echo "\nExample:\n\taoc_setup.ksh -d 2016-09-29 -t 1721-2000 -c 8 -e /path/to/est/sita/log -w /path/to/wst/sita/log\n\n"
	exit
}
DATE=$( date +"%Y-%m-%d" ) 
TIME="0000-$( date +"%H%M" )"

if [[ -z ${1} || ${1} = "h" || ${1} = "-h" ]]; then
	helper
fi
while getopts :h:D:d:t:c:e:w: ARGUMENTS ; do
# getopts needs each flag to have an argument in order to work
	case ${ARGUMENTS} in 
		h) 	helper ;;	
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
chmod -R 755  ${SITA_TEST_REPO}

#Essentially Directory Info tracking
echo "Creating Tracking information file"
echo "${USER} entered:\n\taoc_setup.ksh $*\t on $( date +"%Y%m%d %H:%M:%S Z" )\n\nEST_LOG=${EST_LOG}\nWST_LOG=${WST_LOG}" > ${SITA_TEST_REPO}/EnteredInfo_${DATE}_${TIME}.info


# This for loop/awk combines all "bytes of" messages onto a single line from each sita file, then combines both Est/Wst Logs 
for SITA_LOG in ${EST_LOG} ${WST_LOG}; do
	echo "--------------------------------------------------------------------------------------------------------------------------"
	echo "\nWorking ${SITA_LOG}"
	SITA_LOG_NAME=$( basename ${SITA_LOG} | cut -d "_" -f 1-4 )
	echo "SITA_LOG_NAME=${SITA_LOG_NAME}"

	FIRST_DATE=$( head -1 ${SITA_LOG} | awk '{print $1}' )
	echo "FIRST_DATE=${FIRST_DATE}"

	echo "Cleaning up sita log files now and replacing control characters, tabs, & new lines"
	cat ${SITA_LOG} | 	sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@@@g" | \
						sed -e "s@	@ <TAB> @g"  > ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED
	echo "\nCreated ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED"
	
	echo "\n\nParsing cleaned up log file & adding in header now..."
	ZONAL=$( echo ${SITA_LOG_NAME} | cut -d "_" -f 3 )
	echo "\nparseLogfile.awk -v LOG_DIRECTION=\"${ZONAL}\" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> SITA_LOGS_COMBINED.out"
# I THINK I CAN TAKE OUT THE FIRST DATE VARIABLE
	${HOME}/GIT/AOC_WORK/parseLogfile.awk -v LOG_DIRECTION="${ZONAL}" -v FIRST_DATE="${FIRST_DATE}" ${SITA_TEST_REPO}/${SITA_LOG_NAME}_CLEANED >> ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out
	echo "=========================================================================================================================="
done

print -u1 -n "\nTime sorting SITA_LOGS_COMBINED.out" ##        V this grep removes blank lines
cat ${SITA_TEST_REPO}/SITA_LOGS_COMBINED.out | sort | grep -v -e "^$" > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out
print -u1 -n "   . . . Done\n"

print -u1 -n "\nFiltering out Dates and Times out of range"
${HOME}/GIT/AOC_WORK/calcTotSecs.awk -v DATE="${DATE}" -v TIME="${TIME}" ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED.out > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED.out  2> ${SITA_TEST_REPO}/OUT_OF_RANGE.out
print -u1 -n "   . . . Done\n"

print -u1 -n "\nFixing Header fields with actual data"
${HOME}/GIT/AOC_WORK/fixHeader.awk ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED.out  > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out
print -u1 -n "   . . . Done\n"

print -u1 -n "\nSplitting up lines again"
${HOME}/GIT/AOC_WORK/seperate.awk ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out > ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED_SEPERATED.out
print -u1 -n "   . . . Done\n"

echo "Starting Comparision work... i think"

#ANALYZE_FILE=${SITA_TEST_REPO}/TEST_CASE_FILTER.out
#IGNORED_FILE=${SITA_TEST_REPO}/TEST_CASE_IGNORED.out
#touch ${ANALYZE_FILE}
#touch ${IGNORED_FILE}

#echo "\nGetting TEST CASE LINE"
#for TEST_CASE in $( cat ${CASE} | sed -e "s@ @_@g" | grep "<BEGIN" ); do
#
#	FLID=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $2}' )
#	ITER=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $3}' )
#	TYPE=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $4}' )
#	echo "${FLID} | ${ITER} | ${TYPE}"
##	${HOME}/GIT/AOC_WORK/correspondence.awk -v FLID="${FLID}" -v ITER="${ITER}" -v TYPE="${TYPE}" -v ANALYZE_FILE="${ANALYZE_FILE}" -v IGNORED_FILE="${IGNORED_FILE}" ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out
#
#	GREP_LINE=$( echo ${TEST_CASE} | sed -e "s@_@ @g" | awk '{print $2, $3, $4}' )
#	echo "grepping \"${GREP_LINE}\""
#	grep "${GREP_LINE}" ${SITA_TEST_REPO}/SITA_LOGS_COMBINED_SORTED_FILTERED_FIXED.out >> ${SITA_TEST_REPO}/TEST_CASE_FILTER.out
#done
ls -ltr  ${SITA_TEST_REPO}
