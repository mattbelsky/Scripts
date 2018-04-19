#!/bin/bash

currentDate=$(date "+%m-%d-%Y")
name="$currentDate-matthew-belsky-backups"
bucketPath=s3://$name
localParentPath=/home/matthew/Documents/CodingNomads/challenges/
localChildPath=scripting_challenge/

echo 'Creating new AWS S3 bucket...'

aws s3 mb $bucketPath

echo "Copying files to AWS S3 bucket $name..."

aws s3 cp $localParentPath$localChildPath $bucketPath --recursive --exclude "*" --include "*.jpg" --include "*.txt"

echo "Deleting the folder \"scripting challenge\"..."

rm -r $localParentPath$localChildPath

echo "Making a new folder named $currentDate..."

mkdir $localParentPath$currentDate

cd $localParentPath$currentDate

echo "Copying the contents of bucket $name to folder $currentDate..."

aws s3 cp $bucketPath $localParentPath$currentDate --recursive --exclude "*" --include "*.jpg" --include "*.txt"
