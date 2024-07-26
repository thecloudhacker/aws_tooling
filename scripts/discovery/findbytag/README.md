# Find Infrastructure by Tags

Discover infrastructure by tags - an option that's not always available in the AWS Web console. These scripts support finding infrastructure in your AWS cloud environment by a tag key and a tag value.

Using AWS API calls we can iterate over items to find objects by tags and types.

[Find by Tag](findbytag.sh)  <---- Use this to search through multiple infrastructure types

Provide the tag key and tag value to search on and the aws account profile to use
```./findbytag.sh “TagKey” “TagValue” "AWS PROFILE"```
e.g. 
```./findbytag.sh "sv:team" "DevSecOps" "prod"```

---

Individual functions used in the process:
- [S3 Items based on tags](s3_by_tags.sh)
- [Step Function Items based on tags](stepfunction_by_tags.sh)
- [RDS based on tags](./rds_by_tags.sh)
- [Secrets based on tags](./secrets_by_tags.sh)
- [EC2 based on tags](./ec2_by_tags.sh)