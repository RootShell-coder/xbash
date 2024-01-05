#!/bin/bash
set -e

#tested GITALB v16.x

#TOKEN="Gitlab token"
GITLAB_GROUP_API_TOKEN=${GITLAB_GROUP_API_TOKEN:-$TOKEN}
GITLAB_URL="https://gitlab.com"
PER_PAGE=100
LEAVE_LAST_PIPELINE=5

case "$1" in

making)
curl -sk --request GET --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "${GITLAB_URL}/api/v4/projects?per_page=100" | jq '[.[] | {id: .id, name: .name}]'
;;

pipeline)
clean_artifacts(){
  if [[ ${3} -gt 0 ]]; then
    RESPONSE=$(curl -isk --request DELETE --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "${GITLAB_URL}/api/v4/projects/${1}/jobs/${2}/artifacts" | grep -i "HTTP/2" | awk '{print $2}' | tr -d '[:space:]' || exit 0)
    if [[ ${RESPONSE} -eq 204 ]]; then
      curl -sk --request POST --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "${GITLAB_URL}/api/v4/projects/${1}/jobs/${2}/erase"  > /dev/null || exit 0
    fi
  fi
}

clean_pipeline(){
  curl -sk --request "DELETE" --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "$GITLAB_URL/api/v4/projects/${1}/pipelines/${2}"  > /dev/null || exit 0
}

jobs(){
  JOBS_ID=()
  PIPELINE_ID=()
  ARTIFACTS=()
  DEL_PIPELINE=()
  PAGE=1
  while : ; do
    NEXT_PAGE=$(curl -Isk --request GET --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "${GITLAB_URL}/api/v4/projects/${1}/jobs?per_page=${PER_PAGE}&page=${PAGE}" | grep -i "x-next-page:" | awk '{print $2}' | tr -d '[:space:]' || exit 0)
    JOBS=$(curl -sk --request GET --header "PRIVATE-TOKEN: $GITLAB_GROUP_API_TOKEN" "${GITLAB_URL}/api/v4/projects/${1}/jobs?per_page=${PER_PAGE}&page=${PAGE}" || exit 0 )
    JOBS_LENGTH=$(echo $JOBS | jq 'map(.id) | length')
    for (( i=0; i<${JOBS_LENGTH}; i++ )); do
      JOBS_ID+=($(echo ${JOBS} | jq '.['$i'].id'))
      PIPELINE_ID+=($(echo ${JOBS} | jq '.['$i'].pipeline.id'))
      ARTIFACTS+=($(echo ${JOBS} | jq -e 'try(.['$i'].artifacts[0].size) // 0'))
    done
    if [[ -z ${NEXT_PAGE} ]]; then break; else PAGE=${NEXT_PAGE}; fi
  done
  SORT_ID=($(echo "${PIPELINE_ID[@]}" | tr ' ' '\n' | sort -ur | tr '\n' ' '))
  for(( x=${LEAVE_LAST_PIPELINE}; x<${#SORT_ID[@]}; x++)); do
    DEL_PIPELINE+=($(echo ${SORT_ID[x]}))
  done
  for (( a=0; a<${#JOBS_ID[@]}; a++ )); do
    if [[ ${DEL_PIPELINE[@]} =~ ${PIPELINE_ID[a]} ]]; then
      echo -e "\033[91m${1}\t\t${PIPELINE_ID[a]}\t\t${JOBS_ID[a]}\t\t${ARTIFACTS[a]}\033[39m"
      clean_artifacts "${1}" "${JOBS_ID[a]}" "${ARTIFACTS[a]}"
      else
      echo -e "\033[92m${1}\t\t${PIPELINE_ID[a]}\t\t${JOBS_ID[a]}\t\t${ARTIFACTS[a]}\033[39m"
    fi
  done
  for (( s=0; s<${#DEL_PIPELINE[@]}; s++ )); do
    clean_pipeline "${1}" "${DEL_PIPELINE[s]}"
  done
}

main(){
  PROJECT=( $(cat ./id_proj.json | jq '.[].id') )
  echo ""
  echo -e "\033[91mDelete pipeline\033[39m/\033[92mLeave pipeline\033[39m variable LEAVE_LAST_PIPELINE=${LEAVE_LAST_PIPELINE}"
  echo -e "PROJECT\t\tPIPELINES\tJOBS\t\tARTIFACTS"
    for (( j=0; j<${#PROJECT[@]}; j++ )); do
      PROJECT_NAME=$(cat ./id_proj.json | jq '.['$j'].name')
      jobs "${PROJECT[j]}"
    done
exit 0
}
main
;;

*)
echo $"Usage: $0 { making | pipeline }"
esac
