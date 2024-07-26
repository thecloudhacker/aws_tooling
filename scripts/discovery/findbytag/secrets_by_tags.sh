#!/bin/bash

###
# Find Secret Manager resources by tags
# ------------------------------------
# Provide the tag key and tag value to search on and the aws account profile to use
# ./secrets_by_tags.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./secrets_by_tags.sh "sv:team" "DevSecOps" "prod"
#
#  Notes:
#  -------
#  QUICK AND DIRTY ROUTINE - Doesn't come in a nice format from AWS 
#  so displaying some duf lines in the code.
#


aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3
echo "Beginning Secret Manager search..."

for secrets in $(aws secretsmanager list-secrets --profile $aws_profile --region eu-west-2 --filter Key="\"tag-key\"",Values="\"$aws_tag_key\"" --filter Key="\"tag-value\"",Values="\"$aws_tag_value\"" --no-paginate --output json | jq -r .SecretList[].Name); do
        echo "Secret: $secrets, Tag Key: $aws_tag_key, Tag Value: $aws_tag_value"
done

echo "...Completed"