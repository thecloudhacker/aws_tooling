#!/bin/bash

###
# Find By Tags
# ------------------------------------
#
# Search through a range of infrastructure and output items matching tags
#
# Provide the tag key and tag value to search on and the aws account profile to use
# ./findbytag.sh “TagKey” “TagValue” "AWS PROFILE"
#
# e.g. ./findbytag.sh "sv:team" "DevSecOps" "prod"
#
# Output information: 
# -------------------
# S3 Buckets
# Step Functions
# RDS
# Secrets Manager
# EC2 Instances
# -------------------

aws_tag_key=$1
aws_tag_value=$2
aws_profile=$3

if [ -z ${aws_tag_key} ] || [ -z ${aws_tag_value} ] || [ -z ${aws_profile} ]; then
    echo "Missing Arguments, require Tag Key, Tag Value , AWS Environment"
    exit 0
else
    echo -e "Buckets:\n--------"
    ./s3_by_tags.sh "$aws_tag_key" "$aws_tag_value" "$aws_profile"

    echo -e "Step Functions:\n------------"
    ./stepfunction_by_tags.sh "$aws_tag_key" "$aws_tag_value" "$aws_profile"

    echo -e "RDS:\n--------"
    ./rds_by_tags.sh "$aws_tag_key" "$aws_tag_value" "$aws_profile"

    echo -e "Secrets Manager:\n--------"
    ./secrets_by_tags.sh "$aws_tag_key" "$aws_tag_value" "$aws_profile"

    echo -e "EC2 Instances:\n--------"
    ./ec2_by_tags.sh "$aws_tag_key" "$aws_tag_value" "$aws_profile"
fi