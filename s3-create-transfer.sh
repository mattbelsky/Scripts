#!/bin/bash

echo "Creating new AWS S3 bucket..."

aws s3 mb s3://20180426-backup

echo "Copying notes to S3 bucket..."

aws s3 cp ~/Documents/"CodingNomads Notes.odt" s3://20180426-backup

echo "Finished copying!"
