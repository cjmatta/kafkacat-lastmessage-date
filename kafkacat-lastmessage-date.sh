#!/bin/bash

# Check for Kafkacat
command -v kafkacat >/dev/null 2>&1 || { echo >&2 "This script requires kafkacat but it's not installed.  Aborting."; exit 1; }

print_help() {
    echo "Uses kafkacat to list topics and partitions and the date of the last record in the topic."
    echo 
    echo "$0 -F ~/.ccloud/kafkacat-config [--topic topicname]"
    echo
    echo "  note: a list of topics can be specified with a quoted string: '--topic \"topic1 topic2\"'"
    exit 1
}

# collect flags
while [[ $# -gt 0 ]]; do 
key="$1"

case $key in 
    -F)
    CONFIGFILE="$2"
    shift
    ;;
    --topic)
    TOPICS="$2"
    shift
    ;;
    --help)
    print_help
    ;;
    *)
    print_help
    ;;
esac
shift
done

# No topics specified, get them from kafkacat
if [[ "x${TOPICS}" == "x" ]]; then
    TOPICS=$(kafkacat -F ${CONFIGFILE} -L | grep "^ \+topic" | awk '{print $2}' | tr -d '\"' | grep -v "^_");
fi

printf "\n%-40s %-10s %s\n" "topic" "partition" "last message date"
echo "----------------------------------------------------------------------"
for TOPIC in ${TOPICS}; do 
    PARTITIONOUT=$(kafkacat -q -F ${KAFKACAT_CONFIG} -C -o -1 -e -t ${TOPIC} -f "%p,%T\n" | sort -n +0);
    if [[ "x${PARTITIONOUT}" == "x" ]]; then
            printf "%-40s %s\n" "${TOPIC}" "empty topic"
    else
        for ITEM in ${PARTITIONOUT}; do
            PARTITION=$(echo ${ITEM} | awk -F, '{print $1}')
            LATEST_TS=$(echo ${ITEM} | awk -F, '{print $2}')
            DATE_STRING=$(date -j -r $((${LATEST_TS}/1000)) +'%Y-%m-%d %H:%M:%S')
            printf "%-40s %-10s %s\n" "${TOPIC}" "${PARTITION}" "${DATE_STRING}"
        done
    fi 
        
done