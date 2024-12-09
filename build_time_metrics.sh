#!/usr/bin/env bash
#This script is used to build report for okr-83-metrics pipeline

JENKINS_URL="http://localhost:8080"
USER="admin"
JOB_NAME="test"
API_TOKEN=""
AUTH="${USER}:${API_TOKEN}"
ALL_PR="${JENKINS_URL}/job/${JOB_NAME}/view/change-requests/api/json?tree=jobs[name]"

mapfile -t prTab < <(curl -g -s -u "${AUTH}" "${ALL_PR}" | jq -r '.jobs[].name')

ALL_JOBS_START="${JENKINS_URL}/job/${JOB_NAME}/view/change-requests/job/"
ALL_JOBS_END="/api/json?tree=builds[number,result,timestamp,duration]"
PAUSE="N/A"
OV="**Overall build**"

echo -e "pull_request,build_number,stage,result,start,paused,duration\ln" >> stages.csv
for result in "${prTab[@]}"; do
    ALL_JOBS="${ALL_JOBS_START}${result}${ALL_JOBS_END}"
    curl -g -s -u "${AUTH}" "${ALL_JOBS}" | jq -r --arg pr "${result}" --arg ov "${OV}" --arg pa "${PAUSE}" '.builds[] | "\($pr),\(.number),\($ov),\(.result),\(.timestamp),\($pa),\(.duration)"' >> stages.csv
done
