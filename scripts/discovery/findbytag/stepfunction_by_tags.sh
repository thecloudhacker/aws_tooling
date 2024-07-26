#!/bin/bash

###
# Find Step Function resources by tags
# ------------------------------------
# Provide the tag key and tag value to search on and the aws account profile to use
# ./stepfunction_by_tags.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./stepfunction_by_tags.sh "sv:team" "DevSecOps" "prod"

aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3

echo "Beginning Step Function search..."

for stepfunction in $(aws stepfunctions list-state-machines --region eu-west-2 --output json --profile $aws_profile --no-paginate | jq -r .stateMachines[].stateMachineArn); do
    tags=$(aws stepfunctions list-tags-for-resource --region eu-west-2 --profile $aws_profile --resource-arn $stepfunction --no-paginate 2>/dev/null | jq -r --arg key "$aws_tag_key" '.tags[] | select(.key == $key).value' )
    if [ $? -eq 0 ]; then
        if [ "$tags" == "$aws_tag_value" ]; then
            echo "Step Function: $stepfunction, Tag Key: $aws_tag_key, Tag Value: $aws_tag_value"
        fi
    else
        echo "Error occurred processing step function: $stepfunction"
    fi
done

echo "...Completed"