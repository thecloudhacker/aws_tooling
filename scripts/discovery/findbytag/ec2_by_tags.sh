#!/bin/bash

###
# Find EC2 resources by tags
# ------------------------------------
# Provide the tag key and tag value to search on and the aws account profile to use
# ./ec2_by_tags.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./ec2_by_tags.sh "sv:team" "DevSecOps" "prod"
#
#

aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3
echo "Beginning EC2 search..."
for instances in $(aws ec2 describe-instances --profile $aws_profile --region eu-west-2 --query 'Reservations[*].Instances[*].Tags[?Key == `Name`].Value' --filters Name=tag-key,Values="$aws_tag_key" --filters Name=tag-value,Values="$aws_tag_value" --output text --no-paginate); do
        echo "EC2 Instance: $instances, Tag Key: $aws_tag_key, Tag Value: $aws_tag_value"
done
echo "...Completed"