crontab: 0 0 * * * /path/file

#!/bin/sh
#mongodump -u mongodev -p NyUrSVlhXVNtkjc7QDyYF8 --host=rs0/10.22.0.50:27017,10.22.0.51:27017,10.22.0.52:27017 --authenticationDatabase=admin --out ./backup/
current_date=$(date +"%Y%m%d_%H%M%S")
#if [ -d /mnt/hdd/data_backup/mongodb_dev ]; then
 # rm -rf /mnt/hdd/data_backup/mongodb_dev
 # mkdir /mnt/hdd/data_backup/mongodb_dev
 # mongodump -u mongodev -p NyUrSVlhXVNtkjc7QDyYF8 --host=rs0/10.22.0.50:27017,10.22.0.51:27017,10.22.0.52:27017 --authenticationDatabase=admin | gzip > "/mnt/hdd/data_backup/mongodb_dev/mongo-${current_date}.gz"
#else
 # mkdir /mnt/hdd/data_backup/mongodb_dev
 # mongodump -u mongodev -p NyUrSVlhXVNtkjc7QDyYF8 --host=rs0/10.22.0.50:27017,10.22.0.51:27017,10.22.0.52:27017 --authenticationDatabase=admin | gzip > "/mnt/hdd/data_backup/mongodb_dev/mongo-${current_date}.gz"
#fi

if [ -d /mnt/hdd/data_backup/mongodb_dev ]; then

  # Keep only 3 files newest
  export folder="/mnt/hdd/data_backup/mongodb_dev"
  export files=$(find "$folder" -maxdepth 1 -type f -printf "%T@ %p\n" | sort -nr)
  export files_to_delete=$(echo "$files" | tail -n +1 | cut -d ' ' -f2-)
  rm $files_to_delete

  # dump database
  mongodump -u mongodev -p NyUrSVlhXVNtkjc7QDyYF8 --host=rs0/10.22.0.50:27017,10.22.0.51:27017,10.22.0.52:27017 --authenticationDatabase=admin --archive > "/mnt/hdd/data_backup/mongodb_dev/mongo-${current_date}.dump"
  #rm -rf /mnt/hdd/dump
  #rm -rf /root/dump
  echo "Export database is success!"
fi


