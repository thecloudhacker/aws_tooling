#!/bin/bash

###
# Find S3 resources by tags
# -------------------------
# Provide the tag key and tag value to search on and the aws account profile to use
# ./s3_by_tags.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./s3_by_tags.sh "sv:team" "DevSecOps" "prod"

aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3

echo "Beginning S3 search..."

for bucket in $(aws s3api list-buckets --profile $3 | jq -r .Buckets[].Name); do
    tags=$(aws s3api get-bucket-tagging --profile $3 --bucket $bucket 2>/dev/null | jq -r --arg key "$aws_tag_key" '.TagSet[] | select(.Key == $key).Value')
    if [ $? -eq 0 ]; then
        if [ "$tags" == "$aws_tag_value" ]; then
            echo "Bucket: $bucket, Tag Key: $aws_tag_key, Tag Value: $aws_tag_value"
        fi
    else
        echo "Error occurred processing bucket: $bucket"
    fi
done

echo "...Completed"