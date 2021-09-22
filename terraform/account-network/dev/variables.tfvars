### DEV SPECIFIC VARIABLES ###

## main environment settings
region = "eu-west-2"
networkname = "gingerco"

## network settings
cidr_block = "10.0.0.0/16"
aws_az = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]

public_subnets = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]

private_subnets = ["10.0.0.0/19", "10.0.32.0/19", "10.0.64.0/19"]

