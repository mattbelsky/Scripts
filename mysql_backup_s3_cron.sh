#!/bin/bash

echo "starting DB backup procedure..."

current_time=$(date "+%Y.%m.%d-%H.%M.%S")
echo "Current Time : $current_time"

echo "starting mysqldump..."

mysqldump -u root -p 0.5Lb_$3 University > /home/matthew/Documents/CodingNomads/databases/dumps/$University-test.sql

echo "mysqldump complete."

echo "starting s3 transfer..."

aws s3 cp /home/matthew/Documents/CodingNomads/databases/dumps/$University-test.sql s3://mysql-backup-test-mbelsky

echo "s3 transfer complete! backup can be found at s3://mysql-backup-test-codingnomads/$University-test.sql"

echo "complete."
