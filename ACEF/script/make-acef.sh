#!/bin/bash

my_dir=$(pwd)
acef_dir=$(cd ../ && pwd)

rm -rf /tmp/acef
mkdir /tmp/acef
if [ ${?} != 0 ]
then
	echo "Could not create temp directory /tmp/acef"
	exit 1
fi

database_id="${1}"

if [ "x${database_id}" = "x" ]
then
	echo "$(date '+%Y-%m-%d %H:%M:%S') Retrieving GSD IDs"
	mysql --defaults-extra-file=my.cnf -e 'SELECT record_id FROM `databases`' > /tmp/acef/database_ids.txt
	echo "$(date '+%Y-%m-%d %H:%M:%S') Executing one-off SQL"
	mysql --defaults-extra-file=my.cnf < once.sql
	echo "$(date '+%Y-%m-%d %H:%M:%S') Clearing directory ${acef_dir}"
	rm -rf "${acef_dir}/*.gz"
else
	echo $database_id > /tmp/acef/database_ids.txt
fi

dsql=${my_dir}/datasets_generated.sql
echo "" > ${dsql}
while read -r line
do
	if [ "${line}" = "record_id" ]
	then
		# Skip header
		continue
	fi
    echo "$(date '+%Y-%m-%d %H:%M:%S') Processing database: ${line}"
	mkdir /tmp/acef/${line}
	chmod -R 777 /tmp/acef/${line}
    sed "s/__OUTPUT_DIR__/\/tmp\/acef\/${line}/g" assembly_db_to_acef.sql > /tmp/acef/temp.sql
    sed -i "s/__DATABASE_ID__/${line}/g" /tmp/acef/temp.sql 
    mysql --defaults-extra-file=my.cnf < /tmp/acef/temp.sql
    cd "/tmp/acef/${line}"
    zip_file="/tmp/acef/${line}.tar.gz"
    tar czf ${zip_file} *.txt
    mv ${zip_file} ${acef_dir}
    cd ${my_dir}
    echo "INSERT INTO dataset (key, code, title) VALUES (1000+${line}, null, 'GSD');" >> ${dsql}
done < /tmp/acef/database_ids.txt

