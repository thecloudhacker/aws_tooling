#!/bin/bash

###
# Find RDS resources by tags
# ------------------------------------
# Provide the tag key and tag value to search on and the aws account profile to use
# ./rds_by_tags.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./rds_by_tags.sh "sv:team" "DevSecOps" "prod"
#
#  Notes:
#  -------
#  QUICK AND DIRTY ROUTINE - Doesn't come in a nice format from AWS 
#  so displaying some duf lines in the code.
#


aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3
echo "Beginning RDS search..."

for database in $(aws rds describe-db-instances --region eu-west-2 --profile $aws_profile --query "DBInstances[?contains(TagList[].Key, '$aws_tag_key') && contains(TagList[].Value, '$aws_tag_value')].DBInstanceIdentifier"  --no-paginate --output text ); do
        echo "RDS DB: $database, Tag Key: $aws_tag_key, Tag Value: $aws_tag_value"
done

echo "...Completed"