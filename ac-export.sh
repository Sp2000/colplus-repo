#!/bin/bash

host=localhost
db=colplus
dataset_key=3
export_dir="$(pwd)/ac-export" 

while getopts ":d:h:k:" opt; do
  case $opt in
    d) db="$OPTARG"
    ;;
    h) host="$OPTARG"
    ;;
    k) dataset_key="$OPTARG"
    ;;
    o) export_dir="$OPTARG"
    ;;
    \?) echo "Invalid option -$OPTARG" >&2
    ;;
  esac
done

echo "Export CoL $dataset_key from $host/$db to $export_dir\n\n"
rm -rf $export_dir
mkdir $export_dir

# export csv files
cat ac-export.sql | sed "s/{{datasetKey}}/${dataset_key}/g; s:{{dir}}:${export_dir}:g" | psql -h $host $db

# compress
tar czf "${export_dir}/ac-export.zip" $export_dir/*.csv
