#!/usr/bin/env bash
#This script is used to build report for okr-83-metrics pipeline

: "${USER_NAME?"ERROR: Unknown Username"}"
: "${API_TOKEN?"ERROR: API_TOKEN undefined"}"
: "${DAYS_OLD?"ERROR: DAYS_OLD undefined"}"
JENKINS_URL="http://localhost:8080"
FOLDER="${FOLDER:-"test"}"

set -eEux -o pipefail

DATE_BIN='date'
if command -v gdate >/dev/null 2>&1
then
    DATE_BIN='gdate'
fi

dateStart=$("${DATE_BIN}" -d "${DAYS_OLD}"' days ago' +%s)
auth="${USER_NAME}:${API_TOKEN}"
all_pr="${JENKINS_URL}/job/${FOLDER}/view/change-requests/api/json/?tree=jobs[name]"
job_url_start="${JENKINS_URL}/job/${FOLDER}/view/change-requests/job/"
job_url_end="/api/json?tree=builds[number,result,timestamp,duration]"
pause="N/A"
ov="**overall build**"

if ! command -v jq 2>&1 >/dev/null
then
    curl -sSL https://github.com/jqlang/jq/releases/download/jq-1.7.1/jq-linux-amd64 -o ./jq
    chmod a+x ./jq
    export PATH=./:"$PATH"
fi

get_builds() {
    all_jobs="${job_url_start}${1}${job_url_end}"
    response=$(curl -g -s -u "${auth}" "${all_jobs}")
    if [[ -z "${response}" ]]; then
        echo "ERROR: No response from Jenkins for job ${1}"
        return 1
    fi
    if ! echo "${response}" | jq empty >/dev/null 2>&1; then
        echo "ERROR: Invalid JSON response from Jenkins for job ${1}: ${response}"
        return 1
    fi
    echo "${response}" | jq -r '.builds[] | "\(.number),\(.result),\(.timestamp),\(.duration)"'
}

mapfile -t prTab < <(curl -g -s -v -u "${auth}" "${all_pr}" | jq ".jobs[].name")

echo -e "pull_request,build_number,stage,result,start,paused,duration" > stages.csv
for result in "${prTab[@]}"; do
    get_builds "${result}" | while IFS=, read -r build_number build_result build_timestamp build_duration; do
        if [[ -n "${build_timestamp}" && -n "${build_duration}" ]]; then
            if [ "${build_timestamp}" -ge "${dateStart}" ]; then
                build_timestamp=$(date -d @$((build_timestamp / 1000)) +"%Y-%m-%d")
                build_duration=$(echo "scale=2; $build_duration / 1000 / 60" | bc)
                build_duration=$(echo "$build_duration" | sed 's/^\([0-9]*\.[0-9]\)/0\1/')
                echo -e "${result},${build_number},${ov},${build_result},${build_timestamp},${pause},${build_duration}" >> stages.csv
            fi
        fi
    done
done