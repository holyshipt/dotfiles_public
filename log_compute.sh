#!/usr/bin/env bash

programname=$0

function usage {
  echo "utils that computes log file total sizes given a filter\n"
  echo "log files are generally stored in /opt/<company>/<service>/var/log\n"
  echo "usage: $programname [hostname] [date(e.g., 2019-11-18)] [servicename(e.g., reputation_resolution_service]"
}

set -e

if [ "$#" -ne 3 ]; then
  usage
  exit 1
fi

ssh $1 "du -hca /opt/proofpoint/"$3"/var/log" 2>&1 \
  | (\
    ((grand_total=0))
    while read -r output_line;
    do
      target_date="$2"
      if [[ $output_line == *$target_date* ]]; then
        echo "$output_line";
        raw_size=$(echo $output_line | awk '{ print $1}')
        if [[ $raw_size == *"M"* ]]; then
          real_size=${raw_size%M*}
        elif [[ $raw_size == *"K"* ]]; then
          real_size=${raw_size%K*}
          real_size=$(echo "$real_size/1024.0" | bc)
        #TODO support GB, TB, etc
        fi
        grand_total=$(echo "$grand_total+$real_size" | bc)
        echo "$grand_total"
      fi
    done
    #TODO convert to closest metrics name
    echo "grand total="$grand_total"MB"
  )
